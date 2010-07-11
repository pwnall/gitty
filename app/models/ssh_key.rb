# Public SSL key used to connect to the repositories via git+ssh.
class SshKey < ActiveRecord::Base
  # The key's SSH fingerprint.
  validates :fprint, :presence => true, :length => 1..128, :uniqueness => true
  # A user-friendly name for the key.
  validates :name, :presence => true, :length => 1..128
  # The authorized_keys line for the key.
  validates :key_line, :presence => true, :length => 1..(1.kilobyte)

  # Updates the fingerprint automatically when the key line changes.  
  def key_line=(new_key_line)
    self.fprint = self.class.fingerprint new_key_line
    super
  end

  # A key's fingerprint uniquely identifies the key.  
  def self.fingerprint(key_line)
    key_blob = key_line.split(' ')[1].unpack('m*').first
    Net::SSH::Buffer.new(key_blob).read_key.fingerprint
  end
end
