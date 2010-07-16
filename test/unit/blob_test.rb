require 'test_helper'

class BlobTest < ActiveSupport::TestCase
  def setup
    @repo = repositories(:dexter_ghost)
    @blob = Blob.new :gitid => '5146ab699d565600dc54251c226d6e528b448b93',
                     :repository => @repo
  end
  
  test 'setup' do
    assert @blob.valid?
  end
  
  test 'no duplicate git ids' do
    @blob.gitid = blobs(:d1_d2_a).gitid
    assert !@blob.valid?
  end
  
  test 'repository must be set' do
    @blob.repository = nil
    assert !@blob.valid?
  end
  
  test 'from_git_blob' do
    mock_repository_path @repo
    git_blob = @repo.grit_repo.blob(@blob.gitid)
    blob = Blob.from_git_blob git_blob, @repo
    assert blob.valid?, 'Invalid blob created from git'
    blob.save!
    assert !@blob.valid?, "Blob incorrectly created from git"
  end
end
