module BlobsHelper
  # Relative URI for a blob.
  def blob_path(blob_ref, path)
    path = path[1..-1] if path[0, 1] == '/'
    profile_repository_blob_path(blob_ref.repository.profile,
                                 blob_ref.repository, blob_ref, path)      
  end

  # Relative URI to download a blob.
  def raw_blob_path(blob_ref, path)
    path = path[1..-1] if path[0, 1] == '/'
    raw_profile_repository_blob_path(blob_ref.repository.profile,
                                     blob_ref.repository, blob_ref, path)      
  end
  
  # HTML representation of a blob contents.
  def marked_up_blob(blob, blob_path)
    ext = File.extname blob_path
    if ext == '.md'
      renderer = CodeRenderer.new :filter_html => true,
          :no_styles => true, :safe_links_only => true 
      md = Redcarpet::Markdown.new renderer,
        :autolink => true,
        :no_intra_emphasis => true,
        :tables => true,
        :fenced_code_blocks => true,
        :strikethrough => true,
        :space_after_headers => true
      md.render(blob.data).html_safe
    else
      if GitHub::Markup.can_render?(blob_path)
        GitHub::Markup.render(blob_path, blob.data).html_safe
      else
        lexer = CodeRenderer.pygments_lexer_for_filename blob_path
        code_html = Pygments.highlight blob.data, :lexer => lexer,
            :formatter => 'html', :options => { :encoding => 'utf-8' }
        code_html.html_safe
      end
    end
  end
end

# Markdown HTML renderer augmented to run Pygments on code blocks.
class CodeRenderer < Redcarpet::Render::HTML
  # :nodoc: runs code blocks through Pygments
  def block_code(code, language)
    lexer = CodeRenderer.pygments_lexer_for_language language
    Pygments.highlight code, :lexer => lexer, :formatter => 'html',
                             :options => { :encoding => 'utf-8' }
  end
  
  # Name of the Pygments lexer for a language name specified by a code block.
  def self.pygments_lexer_for_language(language)
    begin
      Pygments.lexer_name_for :lexer => language
    rescue RubyPython::PythonError
      nil
    end
  end
  
  # The pygments lexer to be used for code in a file with the given name.
  def self.pygments_lexer_for_filename(name)
    case name
    when /\.html\.erb$/
      'html+erb'
    when /\.?css\.erb$/
      'css+erb'
    end
    
    begin
      Pygments.lexer_name_for :filename => name
    rescue RubyPython::PythonError
      nil
    end
  end
end
