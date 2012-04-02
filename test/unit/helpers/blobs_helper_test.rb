require 'test_helper'

class BlobsHelperTest < ActionView::TestCase
  setup do
    @branch = branches(:master)
    @commit = commits(:commit1)
    @blob = blobs(:d1_d2_a)
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
  
  test 'raw_blob_path with branch' do
    assert_equal '/dexter/ghost/blob/master/d1/d2/a',
                 blob_path(@branch, '/d1/d2/a')
    assert_equal '/dexter/ghost/raw/master/d1/d2/a',
                 raw_blob_path(@branch, '/d1/d2/a')
  end

  test 'marked_up_blob' do
    mock_repository_path @blob.repository
    html = marked_up_blob @blob, '/d1/d2/a'
    assert html.html_safe?, 'output not marked as html_safe'
    assert_match /<div class="markdpwn-parsed-code">/, html
    assert_no_match /<div class="markdpwn-off-code">/, html
    assert_match "Version 1", html
  end

  test 'marked_up_blob with markdpwn=disabled' do
    mock_repository_path @blob.repository
    ConfigVar['markdpwn'] = 'disabled'
    html = marked_up_blob @blob, '/d1/d2/a'
    assert html.html_safe?, 'output not marked as html_safe'
    assert_match /<div class="markdpwn-off-code">/, html
    assert_no_match /<div class="markdpwn-parsed-code">/, html
    assert_match "Version 1", html
  end
end
