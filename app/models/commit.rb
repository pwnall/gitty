# Commit in a git repository stored on this server.
class Commit < ActiveRecord::Base
  include GitObjectModel
  
  # The repository that the commit is a part of.
  belongs_to :repository
  validates :repository, :presence => true
  
  # The tree committed by this commit.
  belongs_to :tree
  
  # The commit's SHA-1, used as a unique ID.
  validates :gitid, :length => 1..64, :presence => true,
                    :uniqueness => { :scope => :repository_id }
  
  # The author's name.
  validates :author_name, :length => 1..128, :presence => true
  # The author's email.  
  validates :author_email, :length => 1..128, :presence => true
  
  # The committer's name.
  validates :committer_name, :length => 1..128, :presence => true
  # The committer's email.  
  validates :committer_email, :length => 1..128, :presence => true
  
  # The commit message.
  validates :message, :length => 1..1.kilobyte, :presence => true
  
  # Diffs for the blobs changed by the commit.
  has_many :diffs, :class_name => 'CommitDiff', :dependent => :destroy
  
  # The commit's parents.
  has_many :commit_parents, :dependent => :destroy
  has_many :parents, :through => :commit_parents

  # Commit model for an on-disk commit.
  #
  # Args:
  #   git_commit:: a Grit::Commit object
  #   repository:: the Repository that this commit will belong to
  #
  # Returns an unsaved Commit model. It needs to be saved before parent links
  # are created by calling CommitParent#from_git_commit.
  def self.from_git_commit(git_commit, repository)
    tree = repository.trees.where(:gitid => git_commit.tree.id).first
    self.new :repository => repository, :gitid => git_commit.id, :tree => tree,
        :author_name => git_commit.author.name,
        :author_email => git_commit.author.email,
        :committer_name => git_commit.committer.name,
        :committer_email => git_commit.committer.email,
        :authored_at => git_commit.authored_date,
        :committed_at => git_commit.committed_date,
        :message => git_commit.message
  end
  
  # Use git SHAs instead of IDs.
  def to_param
    gitid
  end
  
  # The tree or blob obtained by walking through a path in the commit's tree.
  def walk_path(path)
    tree.walk_path(path)
  end
  
  # A range of commits obtained by walking the commit's parent graph.
  #
  # The commits are ordered by their commit time.
  #
  # Args:
  #   index:: the index of the first commit to be returned; this commit is 0
  #   count:: the number of commits to return
  def walk_parents(index, count)
    enumerator = Commit::Enumerator.new self
    index.times { enumerator.next }    
    commits = []
    count.times do
      break unless commit = enumerator.next
      commits << commit
    end
    commits
  end
end

# Enumerator for a commit's ascendants.
class Commit::Enumerator
  # Creates a new enumerator based at the given commit.
  def initialize(commit)
    @tree = RBTree.new
    @tree[self.class.commit_key(commit)] = commit
  end
  
  # Yields the next ancestor of the master commit.
  def next
    return nil if @tree.empty?
    
    key, commit = *@tree.pop
    commit.parents.each do |parent_commit|
      key = self.class.commit_key parent_commit
      next if @tree.has_key? key
      @tree[key] = parent_commit
    end
    commit
  end
  
  # Determines the sorting order for commits. Larger keys come first.
  def self.commit_key(commit)
    [commit.committed_at.to_f, commit.gitid]
  end
end
