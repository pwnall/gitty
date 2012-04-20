require 'test_helper'

class BlobTest < ActiveSupport::TestCase
  setup do
    @repo = repositories(:dexter_ghost)
    @blob = Blob.new :gitid => '84840e173dd8b77b7451aa2c9346cb69d4ecf0cd',
                     :repository => @repo, :mime_type => 'application/ruby',
                     :size => 12
  end
  
  test 'setup' do
    assert @blob.valid?
  end
  
  test 'no duplicate git ids' do
    @blob.gitid = blobs(:lib_ghost_hello_rb).gitid
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
    assert_equal 44, blob.size
    blob.save!
    assert !@blob.valid?, "Blob incorrectly created from git"
  end
  
  test 'data' do
    mock_repository_path @repo
    assert_equal "Dir['ghost/**/*.rb'].each { |f| require f }\n", @blob.data
    assert_raise TypeError, RuntimeError, 'data are frozen' do
      @blob.data[1] = 'E'
    end
    
    assert_equal ["Dir['ghost/**/*.rb'].each { |f| require f }"],
                 @blob.data_lines
    assert_raise TypeError, RuntimeError, 'data_lines array are frozen' do
      @blob.data_lines[0] = 'New version'
    end
    assert_raise TypeError, RuntimeError, 'data_lines elements are frozen' do
      @blob.data_lines[0][1] = 'E'
    end
    
    assert_equal 1, @blob.data_line_count, 'data_line_count'
  end
end
