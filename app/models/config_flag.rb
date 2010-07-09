# Configuration flags that are global to the installation.
class ConfigFlag < ActiveRecord::Base
  # The name of the configuration flag.
  validates :name, :uniqueness => true, :length => 1..64, :presence => true

  # The value of the configuration flag.
  validates :value, :uniqueness => true, :length => 1..1024, :presence => true

  # Access configuration flags by ConfigFlag['flag_name'].
  def self.[](name)
    unless flag = select(:name => name).first
      raise IndexError, "Configuration flag #{name} not found"
    end
    flag.value
  end
  
  # Set configuration flags by ConfigFlag['flag_name'] = 'flag_value'.
  def self.[]=(name, value)
    flag = select(:name => name).first
    flag ||= new :name => name
    flag.value = value
    flag.save!
    value
  end
end
