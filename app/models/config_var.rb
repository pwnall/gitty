# Configuration flags that are global to the installation.
class ConfigVar < ActiveRecord::Base
  include ConfigvarsRails::Model

  # Add your extensions to the ConfigVar class here.
end
