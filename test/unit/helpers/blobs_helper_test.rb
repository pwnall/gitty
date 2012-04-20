require 'test_helper'

class BlobsHelperTest < ActionView::TestCase
  setup do
    @branch = branches(:master)
    @commit = commits(:hello)
    @blob = blobs(:lib_ghost_hello_rb)
    @gid = @commit.gitid
  end
  
  test 'blob_path with branch' do
    assert_equal '/dexter/ghost/blob/master/lib/ghost/hello.rb',
                 blob_path(@branch, '/lib/ghost/hello.rb')
    assert_equal '/dexter/ghost/raw/master/lib/ghost/hello.rb',
                 raw_blob_path(@branch, '/lib/ghost/hello.rb')
  end

  test 'blob_path with commit' do
    assert_equal "/dexter/ghost/blob/#{@gid}/lib/ghost/hello.rb",
                 blob_path(@commit, 'lib/ghost/hello.rb')
    assert_equal "/dexter/ghost/raw/#{@gid}/lib/ghost/hello.rb",
                 raw_blob_path(@commit, 'lib/ghost/hello.rb')
  end
  
  test 'raw_blob_path with branch' do
    assert_equal '/dexter/ghost/blob/master/lib/ghost/hello.rb',
                 blob_path(@branch, '/lib/ghost/hello.rb')
    assert_equal '/dexter/ghost/raw/master/lib/ghost/hello.rb',
                 raw_blob_path(@branch, '/lib/ghost/hello.rb')
  end

  test 'marked_up_blob' do
    mock_repository_path @blob.repository
    html = marked_up_blob @blob, '/lib/ghost/hello.rb'
    assert html.html_safe?, 'output not marked as html_safe'
    assert_match(/<div class="markdpwn-parsed-code">/, html)
    assert_no_match(/<div class="markdpwn-off-code">/, html)
    assert_match "<div class=\"markdpwn-parsed-code\"><span class=\"no\">STDOUT</span><span class=\"o\">.</span><span class=\"n\">puts</span> <span class=\"o\">[</span><span class=\"ss\">:Hello</span><span class=\"p\">,</span> <span class=\"ss\">:World</span><span class=\"o\">].</span><span class=\"n\">join</span><span class=\"p\">(</span><span class=\"s1\">&#39; &#39;</span><span class=\"p\">)</span>\n</div>", html
  end

  test 'marked_up_blob with markdpwn=disabled' do
    mock_repository_path @blob.repository
    ConfigVar['markdpwn'] = 'disabled'
    html = marked_up_blob @blob, '/lib/ghost/hello.rb'
    assert html.html_safe?, 'output not marked as html_safe'
    assert_match(/<div class="markdpwn-off-code">/, html)
    assert_no_match(/<div class="markdpwn-parsed-code">/, html)
    assert_match "<div class=\"markdpwn-off-code\">STDOUT.puts [:Hello, :World].join(' ')\n</div>", html
  end
end
