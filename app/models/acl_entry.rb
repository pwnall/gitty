# The ACL entry 
class AclEntry < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true
  belongs_to :principal, :polymorphic => true
end
