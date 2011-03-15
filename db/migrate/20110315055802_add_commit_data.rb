class AddCommitData < ActiveRecord::Migration
  def self.up
    FeedItem.all.each do |item|
      next unless item.data[:commits]
      item.data[:commits].each do |commit_data|
        repository = item.target && item.target.repository
        commit = repository && repository.commits.
            where(:gitid => commit_data[:gitid]).first
        if commit
          commit_data[:author] = commit.author_email
        else
          commit_data[:author] = author.display_email
        end
      end
      item.data = item.data
      item.save!
    end
  end

  def self.down
    FeedItem.all.each do |item|
      next unless item.data[:commits]
      item.data[:commits].each do |commit_data|
        commit_data.delete :author
      end
      item.data = item.data
      item.save!
    end
  end
end
