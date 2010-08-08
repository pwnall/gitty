require 'test_helper'

class BlobTest < ActiveSupport::TestCase
  def setup
    @repo = repositories(:dexter_ghost)
    @blob = Blob.new :gitid => '5146ab699d565600dc54251c226d6e528b448b93',
                     :repository => @repo, :mime_type => 'text/plain',
                     :size => 12
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
  
  test 'size must be set' do
    @blob.size = nil
    assert !@blob.valid?
  end
  
  test 'size must be positive' do
    @blob.size = -1
    assert !@blob.valid?
  end
  
  test 'mime_type must be set' do
    @blob.mime_type = nil
    assert !@blob.valid?
  end
  
  test 'from_git_blob' do
    mock_repository_path @repo
    git_blob = @repo.grit_repo.blob(@blob.gitid)
    blob = Blob.from_git_blob git_blob, @repo
    assert blob.valid?, 'Invalid blob created from git'
    assert_equal 'text/plain', blob.mime_type
    assert_equal 12, blob.size
    blob.save!
    assert !@blob.valid?, "Blob incorrectly created from git"
  end
end
