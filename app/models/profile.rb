# The profile of an author (user or group) on the site.
class Profile < ActiveRecord::Base
  # The profile's short name, used in URLs.
  validates :name, :length => 1..32, :format => /\A\w+\Z/, :presence => true,
                   :uniqueness => true
  
  # The profile's long name.
  validates :display_name, :length => 1..256, :presence => true
end
