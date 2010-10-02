# Someone is allowed to perform an operation on an object in the system.
class AclEntry < ActiveRecord::Base
  # The object that an operation is performed on.
  belongs_to :subject, :polymorphic => true
  validates :subject, :presence => true
  
  # The entity that is allowed to perform the operation.
  belongs_to :principal, :polymorphic => true
  validates :principal, :presence => true
  
  # The type of operation that the subject is allowed to perform.
  validates :role, :presence => true, :length => 16
end
