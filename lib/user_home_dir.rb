module UserHomeDir
  def self.for(user_name)
    case RUBY_PLATFORM
    when /darwin/
      File.join '/Users', user_name
    else
      File.join '/home', user_name
    end
  end
end
