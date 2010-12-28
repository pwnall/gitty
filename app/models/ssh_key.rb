# Public SSL key used to connect to the repositories via git+ssh.
class SshKey < ActiveRecord::Base
  # The user that uses the SSH key to authenticate.
  belongs_to :user, :inverse_of => :ssh_keys
  validates :user, :presence => true
  
  # The key's SSH fingerprint.
  validates :fprint, :presence => true, :length => 1..128, :uniqueness => true
  # A user-friendly name for the key.
  validates :name, :presence => true, :length => 1..128
  # The authorized_keys line for the key.
  validates :key_line, :presence => true, :length => 1..(1.kilobyte)

  # Updates the fingerprint automatically when the key line changes.  
  def key_line=(new_key_line)
    new_key_line = new_key_line.strip.gsub(/\r|\n/, '')
    self.fprint = self.class.fingerprint new_key_line
    super(new_key_line)
  end

  # A key's fingerprint uniquely identifies the key.  
  def self.fingerprint(key_line)
    key_blob = key_line.split(' ')[1].unpack('m*').first
    Net::SSH::Buffer.new(key_blob).read_key.fingerprint
  end
end


# :nodoc: authorized_keys file generation
class SshKey
  # The location of the file containing SSH keys for the git user.
  def self.keyfile_path
    File.join UserHomeDir.for(ConfigVar['git_user']), 'repos', '.ssh_keys'
  end
  
  # The location of the shell file that installs the SSH keys for the git user.
  def self.keyfile_installer_path
    File.join UserHomeDir.for(ConfigVar['git_user']), 'install_keys'
  end    
  
  # The authorized_keys line for this key.
  def keyfile_line
    command = [
      '\"' + Rails.root.join('script', 'git_shell.rb').to_s + '\"',
      id, ConfigVar['app_uri'], '$SSH_ORIGINAL_COMMAND'
    ].join(' ')
    
    
    %Q|command="#{command}",no-agent-forwarding,no-port-forwarding,no-pty,| +
        'no-X11-forwarding ' + key_line
  end
  
  # Re-generates the file containing SSH keys for the git user.
  def self.write_keyfile
    File.open(keyfile_path, 'w') do |f|
      SshKey.all.each { |key| f.write key.keyfile_line + "\n" }
    end
    # NOTE: using blank argument to avoid having the path fed to the shell.
    Kernel.system keyfile_installer_path, ''
  end
  
  # Re-generats the file containing SSH keys for the git user.
  def write_keyfile
    self.class.write_keyfile
  end
  after_save :write_keyfile
  after_destroy :write_keyfile
end
