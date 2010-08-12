require 'test_helper'

class BlobsHelperTest < ActionView::TestCase
  setup do
    @branch = branches(:master)
    @commit = commits(:commit1)
    @gid = @commit.gitid
  end
  
  test 'blob_path with branch' do
    assert_equal '/dexter/ghost/blob/master/d1/d2/a',
                 blob_path(@branch, '/d1/d2/a')
    assert_equal '/dexter/ghost/raw/master/d1/d2/a',
                 raw_blob_path(@branch, '/d1/d2/a')
  end

  test 'blob_path with commit' do
    assert_equal "/dexter/ghost/blob/#{@gid}/d1/d2/a",
                 blob_path(@commit, 'd1/d2/a')
    assert_equal "/dexter/ghost/raw/#{@gid}/d1/d2/a",
                 raw_blob_path(@commit, 'd1/d2/a')
  end
end
