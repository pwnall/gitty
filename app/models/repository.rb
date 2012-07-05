# Git repository hosted on this server.
class Repository < ActiveRecord::Base
  # The profile representing the repository's author.
  belongs_to :profile, :inverse_of => :repositories
  validates :profile, :presence => true
  
  # Virtual attribute, backed by profile_id.
  def profile_name
    @profile_name ||= profile && profile.name
  end
  def profile_name=(new_profile_name)
    self.profile = new_profile_name &&
        Profile.where(:name => new_profile_name).first    
    @profile_name = profile && profile.name
  end
  attr_accessible :profile_name
  
  # Branch information cached from the on-disk repository.
  has_many :branches, :dependent => :destroy, :inverse_of => :repository
  # Tag information cached from the on-disk repository.
  has_many :tags, :dependent => :destroy, :inverse_of => :repository
  # Commit information cached from the on-disk repository.
  has_many :commits, :dependent => :destroy, :inverse_of => :repository
  # Tree information cached from the on-disk repository.
  has_many :trees, :dependent => :destroy, :inverse_of => :repository
  # Blob information cached from the on-disk repository.
  has_many :blobs, :dependent => :destroy, :inverse_of => :repository
  # Submodule information cached from the on-disk repository.
  has_many :submodules, :dependent => :destroy, :inverse_of => :repository
  
  # This repository's ACL. All entries have Profiles as principals.
  has_many :acl_entries, :as => :subject, :dependent => :destroy,
                         :inverse_of => :subject
                         
  # The issues created against this repository.
  has_many :issues, :inverse_of => :repository, :dependent => :destroy
  
  # The repository name.
  validates :name, :length => 1..64, :format => /\A\w([\w.-]*\w)?\Z/,
                   :presence => true,
                   :uniqueness => { :scope => :profile_id }
  validates_each :name do |record, attr, value|
    if /\.git$/ =~ value
      record.errors.add attr, "Don't use .git in the repository name."
    end
  end
  attr_accessible :name

  # Usually a blog post introducing the repository's contents, or a development site.
  validates :url, :length => { :in => 1..256, :allow_nil => true },
                  :format => { :with => /\Ahttps?:\/\//, :allow_nil => true,
                               :message => 'must be a http or https URL' }
  attr_accessible :url

  # Public repositories grant read access to anyone.
  validates :public, :inclusion => [true, false]
  attr_accessible :public
    
  def url=(new_url)
    new_url = nil if new_url.blank?
    super new_url
  end
  
  # A description for the contents of the repository.
  validates :description, :length => { :in => 1..1.kilobyte, :allow_nil => true }
  def description=(new_description)
    new_description = nil if new_description.blank?
    super new_description
  end
  attr_accessible :description

  # The repository's location on disk.
  def local_path
    self.class.local_path profile, name
  end
  
  # The on-disk location of a repository.
  #
  # Args:
  #   profile:: the profile owning the repository
  #   name:: the repository's name
  def self.local_path(profile, name)
    File.join profile.local_path, name + '.git'
  end
  
  # The repository's URL for SSH access.
  def ssh_uri
    ssh_root = "#{ConfigVar['git_user']}@#{ConfigVar['ssh_host']}" 
    "#{ssh_root}:#{ssh_path}"
  end
  
  # The relative path in the repository's SSH access uri.
  def ssh_path
    "#{profile.name}/#{name}.git"
  end
  
  # The Grit::Repo object for this repository.
  def grit_repo
    @grit_repo ||= !(new_record? || destroyed?) && Grit::Repo.new(local_path)
  end
  
  # Use the repository name instead of ID in all routes.
  def to_param
    name
  end
  
  # The repository matching a SSH path, or nil if no such repository exists.
  #
  # This method returns nil for invalid SSH paths. Valid paths are contained in
  # ssh URIs generated by Repository#ssh_uri.
  def self.find_by_ssh_path(ssh_path)
    return nil unless path_info = parse_ssh_path(ssh_path)
    unless repo_profile = Profile.where(:name => path_info[:profile_name]).first
      return nil
    end
    repo_profile.repositories.where(:name => path_info[:repo_name]).first
  end
  
  # Breaks down a SSH path into a profile name and a repository name.
  #
  # Returns a hash with the :profile_name and :repo_name keys set to appropriate
  # values, or nil if the given string is not a valid SSH path.
  def self.parse_ssh_path(ssh_path)
    return nil unless match = /\A(\w+)\/(\w([\w.-]*\w)?)\.git\Z/.match(ssh_path)
    { :profile_name => match[1], :repo_name => match[2] }
  end
end


# :nodoc: keep on-disk repositories synchronized
class Repository
  after_create :create_local_repository
  before_save :save_old_repository_identity
  after_update :relocate_local_repository
  after_destroy :delete_local_repository

  # Creates a Git repository on disk.
  def create_local_repository
    # TODO: background job.
    @grit_repo = Grit::Repo.init_bare local_path
    FileUtils.chmod_R 0770, local_path
    begin
      FileUtils.chown_R ConfigVar['git_user'], nil, local_path
    rescue ArgumentError
      # Happens in unit testing, when the git user isn't created yet.
      raise unless Rails.env.test?
    rescue Errno::EPERM
      # Not root, not allowed to chown.
    end
    
    @grit_repo
  end
  
  # Relocates a Git repository on disk.
  def self.relocate_local_repository(old_profile, profile, old_name, name)
    # TODO: maybe this should be a background job.
    old_path = local_path old_profile, old_name
    new_path = local_path profile, name
    FileUtils.mkdir_p File.dirname(new_path)
    FileUtils.mv old_path, new_path
  end
  
  # Saves the repository's old name and profile, so it can be relocated.
  def save_old_repository_identity
    @_old_repository_name = name_change && name_change.first 
    @_old_repository_profile_id = profile_id_change && profile_id_change.first
  end
  
  # Relocates the on-disk repository if the model's name or profile is changed.
  def relocate_local_repository
    return unless @_old_repository_name or @_old_repository_profile_id
    old_name = @_old_repository_name || name
    old_profile_id = @_old_repository_profile_id || profile_id

    old_profile = Profile.where(:id => old_profile_id).first
    self.class.relocate_local_repository old_profile, profile, old_name, name
    @grit_repo = nil
  end    
  
  # Deletes the on-disk repository. 
  def delete_local_repository
    # TODO: background job.    
    FileUtils.rm_r local_path if File.exist? local_path
    @grit_repo = nil
  end
end

# :nodoc: synchronization with on-disk repositories
class Repository
  # Differences between the on-disk branches and the database models.
  #
  # Returns a hash with the following keys:
  #   :added:: array of Grit::Head objects for new branches
  #   :deleted:: array of Branch models that have been removed
  #   :changed:: hash of Branch models to Grit::Head objects for branches whose
  #              commit pointers have changed
  def branch_changes
    delta = {:added => [], :deleted => [], :changed => {}}    
    db_branches = self.branches.all.index_by(&:name)
    grit_repo.branches.each do |git_branch|
      if branch = db_branches.delete(git_branch.name)
        if branch.commit.gitid != git_branch.commit.id
          delta[:changed][branch] = git_branch
        end
      else
        delta[:added] << git_branch
      end
    end
    delta[:deleted] = db_branches.values
    delta
  end
  
  # Differences between the on-disk tags and the database models.
  #
  # Returns a hash with the following keys:
  #   :added:: array of Grit::Tag objects for new tags
  #   :deleted:: array of Tag models that have been removed
  #   :changed:: hash of Tag models to Grit::Tag objects for tags whose
  #              commit pointers have changed
  def tag_changes
    delta = {:added => [], :deleted => [], :changed => {}}    
    db_tags = self.tags.all.index_by(&:name)
    grit_repo.tags.each do |git_tag|
      if tag = db_tags.delete(git_tag.name)
        if tag.commit.gitid != git_tag.commit.id ||
            tag.message != git_tag.message ||
            tag.committed_at != git_tag.tag_date 
          delta[:changed][tag] = git_tag
        end
      else
        delta[:added] << git_tag
      end
    end
    delta[:deleted] = db_tags.values
    delta
  end
    
  
  # Commits that don't have associated database models.
  #
  # Args:
  #   git_refs:: array of Grit::Ref objects representing on-disk branches or
  #              tags used as starting points for searching for commits
  #
  # Returns an array of Grit::Commit objects, topologically sorted. This means
  # that, if the commits are created in order, a commit's parents will always
  # exist before it is created.
  def commits_added(git_refs)
    db_ids = {}  # f(commit git id) -> {true, false} if it's in the db or not
    
    roots = git_refs.map(&:commit)
    root_ids = roots.map(&:id)
    db_roots = Set.new self.commits.select(:gitid).
                                    where(:gitid => root_ids).map(&:gitid)
    root_ids.each { |root_id| db_ids[root_id] = db_roots.include? root_id }
    roots = roots.reject { |root| db_ids[root.id] }
    
    topological_sort roots do |commit|
      parents = commit.parents
      unknown_ids = parents.map(&:id).reject { |p_id| db_ids.has_key? p_id }
      db_ids2 = Set.new self.commits.select(:gitid).
                                     where(:gitid => unknown_ids).map(&:gitid)
      unknown_ids.each { |p_id| db_ids[p_id] = db_ids2.include? p_id }

      parents = parents.reject { |parent| db_ids[parent.id] }
      { :id => commit.id, :next => parents }
    end
  end
  
  # Trees, blobs, and submodules that don't have associated database models.
  #
  # Args:
  #   git_branches:: array of Grit::Head objects representing on-disk branches
  #                  used as starting points for searching for commits
  #
  # Returns a hash with the follwing keys:
  #   blobs:: array of Grit::Blob objects
  #   submodules:: array of Grit::Submodule objects
  #   trees:: array of Grit::Tree objects, topologically sorted. This means
  #           that, if the trees are created in order, a tree's children will
  #           always exist before it is created.
  def contents_added(git_commits)
    db_ids = {}  # f(tree git id) -> {true, false} if it's in the db or not
    
    roots = git_commits.map(&:tree)
    root_ids = roots.map(&:id)
    db_roots = Set.new self.trees.select(:gitid).
                                  where(:gitid => root_ids).map(&:gitid)
    root_ids.each { |root_id| db_ids[root_id] = db_roots.include? root_id }
    roots = roots.reject { |root| db_ids[root.id] }
    
    new_trees = topological_sort roots do |tree|
      parents = tree.contents.select { |child| child.kind_of? Grit::Tree }
      unknown_ids = parents.map(&:id).reject { |p_id| db_ids.has_key? p_id }
      db_ids2 = Set.new self.trees.select(:gitid).
                                   where(:gitid => unknown_ids).map(&:gitid)
      unknown_ids.each { |p_id| db_ids[p_id] = db_ids2.include? p_id }

      parents = parents.reject { |parent| db_ids[parent.id] }
      { :id => tree.id, :next => parents }
    end
    
    new_blobs = new_trees.map { |tree|
      tree.contents.select { |child| child.kind_of? Grit::Blob }
    }.flatten.index_by(&:id).values
    new_ids = new_blobs.map(&:id)
    db_ids = Set.new self.blobs.select(:gitid).
                                where(:gitid => new_ids).map(&:gitid)
    new_blobs.reject! { |blob| db_ids.include? blob.id }
    
    new_submodules = new_trees.map { |tree|
      tree.contents.select { |child| child.kind_of? Grit::Submodule }
    }.flatten.index_by { |sub| [sub.basename, sub.id] }.values
    new_ids = new_submodules.map(&:id)
    new_names = new_submodules.map(&:basename)
    db_keys = Set.new self.submodules.select([:gitid, :name]).
        where(:gitid => new_ids, :name => new_names).
        map { |sub| [sub.gitid, sub.name] }
    new_submodules.reject! { |sub| db_keys.include? [sub.id, sub.basename] }
    
    { :blobs => new_blobs, :submodules => new_submodules, :trees => new_trees }
  end
  
  # Integrates changes to the on-disk repository into the database.
  #
  # Returns a hash with the following keys:
  #   :commits:: set of Commit models created from the on-disk repository
  #   :branches:: hash with the following keys:
  #                 added:: array of Branch models created from the on-disk
  #                         repository
  #                 changed:: array of Branch models whose head commit changed
  #                 deleted: array of Branch models removed from the on-disk
  #                          repository
  #   :tags:: hash with the following keys:
  #                 added:: array of Tag models created from the on-disk
  #                         repository
  #                 changed:: array of Tag models whose head commit changed
  #                 deleted: array of Tag models removed from the on-disk
  #                          repository
  def integrate_changes
    self.update_http_info

    changes = {}
    
    branch_delta = self.branch_changes
    tag_delta = self.tag_changes
    changed_git_refs = branch_delta[:added] + branch_delta[:changed].values +
                       tag_delta[:added] + tag_delta[:changed].values
    new_git_commits = self.commits_added changed_git_refs
    new_contents = self.contents_added new_git_commits
    
    new_contents[:blobs].each do |git_blob|
      Blob.from_git_blob(git_blob, self).save!
    end
    new_contents[:submodules].each do |git_submodule|
      Submodule.from_git_submodule(git_submodule, self).save!
    end
    new_contents[:trees].each do |git_tree|
      tree = Tree.from_git_tree(git_tree, self)
      tree.save!
      
      tree_entries = TreeEntry.from_git_tree git_tree, self, tree
      tree_entries.each(&:save!)
    end
    new_commits = Set.new
    new_git_commits.each do |git_commit|
      commit = Commit.from_git_commit(git_commit, self)
      commit.save!
      new_commits << commit

      commit_parents = CommitParent.from_git_commit git_commit, self, commit
      commit_parents.each(&:save!)
      
      commit_diffs = CommitDiff.from_git_commit git_commit, commit
      commit_diffs.each do |diff, hunks|
        diff.save!
        hunks.each(&:save!)
      end
    end
    new_branches = []
    branch_delta[:added].each do |git_branch|
      branch = Branch.from_git_branch(git_branch, self)
      branch.save!
      new_branches << branch
    end
    changed_branches = []
    branch_delta[:changed].each do |branch, git_branch|
      branch = Branch.from_git_branch(git_branch, self, branch)
      branch.save!
      changed_branches << branch
    end    
    branch_delta[:deleted].each { |branch| branch.destroy }
    new_tags = []
    tag_delta[:added].each do |git_tag|
      tag = Tag.from_git_tag(git_tag, self)
      tag.save!
      new_tags << tag
    end
    changed_tags = []
    tag_delta[:changed].each do |tag, git_tag|
      tag = Tag.from_git_tag(git_tag, self, tag)
      tag.save!
      changed_tags << tag
    end    
    tag_delta[:deleted].each { |tag| tag.destroy }
    
    { :commits => new_commits,
      :branches => { :added => new_branches, :changed => changed_branches,
                     :deleted => branch_delta[:deleted] },
      :tags => { :added => new_tags, :changed => changed_tags,
                 :deleted => tag_delta[:deleted] } }
  end
end

# :nodoc: support for http sync
class Repository
  # Path to a file inside the raw repository.
  # 
  # This should only be used to implement low-level functionality, such as
  # git-over-http.
  def internal_file_path(file)
    File.join local_path, file
  end

  # The MIME type for a file inside a repository.
  def internal_file_mime_type(file)
    if file[0, 8] == 'objects/'
      if file[8, 5] == 'pack/'
        return 'application/x-git-packed-objects' if file[-5, 5] == '.pack'
        return 'application/x-git-packed-objects-toc' if file[-4, 4] == '.idx'
      elsif file[8, 5] == 'info/'
        return 'text/plain; charset=utf-8' if file == 'objects/info/packs'
      elsif /^objects\/[0-9a-f]+\/[0-9a-f]+$/ =~ file
        return 'application/x-git-loose-object'
      end
    elsif file == 'info/refs'
      return 'text/plain; charset=utf-8'
    end
    'text/plain'
  end

  # True if the given file inside a repository will never change.
  # 
  # This is intended to help make caching decisions.
  def internal_file_immutable?(file)
    # loose files
    return true if /^objects\/[0-9a-f]+\/[0-9a-f]+$/ =~ file
    # packs
    return true if /^objects\/pack\// =~ file

    false
  end

  # Runs a command inside the repository's directory.
  #
  # This method should be used for running low-level commands on the
  # repository, such as git gc.
  #
  # @param [String] binary the program to be executed
  # @param [Array<String>] args arguments for the program to be executed
  # @return [String] the program's stdout
  def run_command(binary, args = [])
    child = POSIX::Spawn::Child.new binary, *args, :chdir => local_path
    return child.out if child.status.success?

    # TODO(pwnall): consider logging the command and stderr to some admin tool
    raise "Non-zero exit code #{child.status.exitstatus} running #{binary} #{args.inspect}."
  end

  # Re-generates the files used by the dumb git-over-HTTP protocol.
  def update_http_info
    run_command 'git', ['repack']
    run_command 'git', ['update-server-info']
  end

  # Runs a data-intensive command inside the repository's directory.
  # 
  # This method should be used for running low-level commands on the
  # repository, such as git gc. The method is optimized for commands that
  # consume or produce a lot of data.
  #
  # @param [String] binary the program to be executed
  # @param [Array<String>] args arguments for the program to be executed
  # @param [#read, #eof?] input_io IO-like object supplying the command's stdin
  # @param [Integer] buffer_size the size of the read/write buffer to be used
  #     for streaming data into and out of the sub-process running the command
  # @return [#each] object implementing the Rails protocol for streaming output
  def stream_command(binary, args = [], input_io = nil, buffer_size = 8192)
    StreamCommandWrapper.new binary, args, local_path, input_io, buffer_size
  end

  # :nodoc: implements stream_command
  class StreamCommandWrapper
    # Launches a sub-process running the command.
    def initialize(binary, args, chdir, input_io, buffer_size)
      @pid, @stdin, @stdout, @stderr = POSIX::Spawn.popen4 binary, *args,
                                                           :chdir => chdir
      @input_io = input_io
      @buffer_size = buffer_size
    end

    # Communicates with the sub-process running the command.
    def each
      if @input_io
        until @input_io.eof?
          @stdin.write @input_io.read(@buffer_size)
        end
        @stdin.close
      end

      until @stdout.eof?
        yield @stdout.read @buffer_size
      end
      @stdout.close
      @stderr.read
      @stderr.close
      Process.wait @pid
      self
    end
  end
end

# :nodoc: access control
class Repository
  # True if the user can read the repository.
  #
  # Reading implies git pull rights.
  def can_read?(user)
    return true if public?
    can_x? user, [:read, :commit, :edit], [:participate, :charge, :edit]
  end
  
  # True if the user can commit to the repository.
  #
  # Committing means the user can push branches and tags.
  def can_commit?(user)
    can_x? user, [:commit, :edit], [:participate, :charge, :edit]
  end
  
  # True if the user can edit (administrate) the repository.
  #
  # Administrating implies changing the repository ACL, as well as renaming and
  # deleting the repository. 
  def can_edit?(user)
    # NOTE: users who can charge the profile can always edit the repo by
    #       deleting it and creating a similar repo with the same name 
    can_x? user, [:edit], [:charge, :edit]
  end
  
  def can_x?(user, profile_role, user_role)
    return false if !user
    profile_ids = user.acl_entries.
        where(:role => user_role, :subject_type => 'Profile').map(&:subject_id)
    acl_entries.exists?(:role => profile_role, :principal_type => 'Profile',
                        :principal_id => profile_ids)
  end
  
  private :can_x?
end

# :nodoc: almost-UI
class Repository
  # The repository branch shown if no other branch is specified.
  def default_branch
    branches.where(:name => 'master').first || branches.first
  end
end

# :nodoc: set up an ACL entry for the repository
class Repository
  before_save :save_old_profile
  after_save :add_acl_entry
  
  # Saves the user's current profile for the post-save ACL fixup.
  def save_old_profile
    @_old_profile_id = profile_id_change ? profile_id_change.first : false
    true
  end
  
  # Creates an ACL entry for the user's profile.
  def add_acl_entry
    return if @_old_profile_id == false
    
    old_profile = @_old_profile_id && Profile.find(@_old_profile_id)
    AclEntry.set old_profile, self, nil if old_profile
    AclEntry.set profile, self, :edit if profile
  end
  
  # All the valid ACL roles when a Repository is the subject.   
  def self.acl_roles
    [
      ['Reader', :read],
      ['Committer', :commit],
      ['Administrator', :edit]
    ]
  end
  
  # Expected class of principals on ACL entries whose subjects are Repositories. 
  def self.acl_principal_class
    Profile
  end  
end

# :nodoc: to be pulled into feed plugin 
class Repository
  # Profiles following this repository.
  has_many :subscribers, :through => :subscriber_feed_subscriptions,
                         :source => :profile

  # Relation backing "subscribers".
  #
  # NOTE: The :dependent => :destroy option removes the FeedSubscriptions
  #       connecting subscribers, not the actual subscribers
  has_many :subscriber_feed_subscriptions, :class_name => 'FeedSubscription',
           :as => :topic, :inverse_of => :topic, :dependent => :destroy
  
  # Events connected to this repository.
  has_many :feed_items, :through => :feed_item_topic
  
  # Relation backing "feed_items".
  #
  # NOTE: The :dependent => :destroy option doesn't remove the FeedItem records,
  #       it only removes the FeedItemTopic records connecting to them.
  has_many :feed_item_topic, :as => :topic, :dependent => :destroy,
                             :inverse_of => :topic

  # Recently created events connected with this repository.
  def recent_feed_items(limit = 100)
    feed_items.order('created_at DESC').limit(limit)
  end
  
  # True if the given profile is subscribed to this repository's feeds.
  def subscribed?(profile)
    subscriber_feed_subscriptions.where(:profile_id => profile.id).first ?
        true : false
  end
  
  # Updates feeds to reflect that this repository was created.
  def publish_creation(author_profile)
    # Duplicating the profile and repository name because the repository record
    # can be deleted.
    FeedItem.publish author_profile, 'new_repository', self, [author_profile,
        self.profile, self], { :profile_name => profile.name,
                               :repository_name => self.name }
  end
  
  # Updates feeds to reflect that this repository was destroyed.
  def publish_deletion(author_profile)
    FeedItem.publish author_profile, 'del_repository', self, [author_profile,
        self.profile], { :profile_name => profile.name,
                         :repository_name => self.name }
  end
  
  # Updates feeds to reflect changes made by a push.
  #
  # Args:
  #   author_profile:: profile that gets credited for the change
  #   changes:: result of call to integrate_changes
  #
  # Returns an array of published FeedItems.
  def publish_changes(author_profile, changes)
    publish_branch_changes(author_profile, changes) +
        publish_tag_changes(author_profile, changes)
  end

  # Updates feeds to reflect branch changes made by a push. 
  #
  # Args:
  #   author_profile:: profile that gets credited for the change
  #   changes:: result of call to integrate_changes
  #
  # Returns an array of published FeedItems.
  def publish_branch_changes(author_profile, changes)
    topics = [author_profile, self, self.profile]
    data_root = { :profile_name => profile.name,
                  :repository_name => name, :repository_id => id }
    delta = []
    [:changed, :added, :deleted].each do |change_type|
      changes[:branches][change_type].each do |branch|
        delta << [change_type, branch]
      end
    end
    
    delta.map do |change_type, branch|
      data = data_root.merge :branch_name => branch.name
      if change_type != :deleted
        commits = branch.commit.walk_parents(0, 16).
            select { |commit| changes[:commits].include? commit }[0, 3]
        data[:commits] = commits.map do |commit|
          { :gitid => commit.gitid, :message => commit.message[0, 100],
            :author => commit.author_email }
        end
      end
      verb = {:added => 'new_branch', :changed => 'move_branch',
              :deleted => 'del_branch'}[change_type]
      FeedItem.publish author_profile, verb, branch, topics, data
    end
  end
  
  # Updates feeds to reflect tag changes made by a push. 
  #
  # Args:
  #   author_profile:: profile that gets credited for the change
  #   changes:: result of call to integrate_changes
  #
  # Returns an array of published FeedItems.
  def publish_tag_changes(author_profile, changes)
    topics = [author_profile, self, self.profile]
    data_root = { :profile_name => profile.name,
                  :repository_name => name, :repository_id => id }
    delta = []
    [:changed, :added, :deleted].each do |change_type|
      changes[:tags][change_type].each { |tag| delta << [change_type, tag] }
    end
    
    delta.map do |change_type, tag|
      data = data_root.merge :tag_name => tag.name
      if change_type != :deleted
        data[:message] = tag.message[0, 100]
        data[:commit] = { :gitid => tag.commit.gitid,
          :message => tag.commit.message[0, 100],
          :author => tag.commit.author_email
        }
      end
      
      verb = {:added => 'new_tag', :changed => 'move_tag',
              :deleted => 'del_tag'}[change_type]
      FeedItem.publish author_profile, verb, tag, topics, data
    end
  end
end
