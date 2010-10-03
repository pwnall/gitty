# Someone is allowed to perform an operation on an object in the system.
class AclEntry < ActiveRecord::Base
  # The object that an operation is performed on.
  belongs_to :subject, :polymorphic => true
  validates :subject, :presence => true
  
  # The entity that is allowed to perform the operation.
  belongs_to :principal, :polymorphic => true
  validates :principal, :presence => true
  
  # The type of operation that the subject is allowed to perform.
  validates :role, :presence => true, :length => 1..16
  
  validates :principal_id, :uniqueness => {:scope => [:principal_type, 
      :subject_id, :subject_type]}
      
  # Sets the principal-subject ACL entry to role. Role can be nil.
  def self.set(principal, subject, role)
    conditions = where_clause principal, subject
    entry = where(conditions).first
    if role
      entry ||= new conditions
      entry.role = role
      entry.save
    else
      entry.destroy if entry
    end
  end
  
  # The role in a principal-subject ACL entry. Nil if there is no entry.
  def self.get(principal, subject)
    entry = where(where_clause(principal, subject)).first
    entry && entry.role.to_sym
  end
  
  # Used to find or construct a principal-subject ACL entry. 
  def self.where_clause(principal, subject)
    { :principal_id => principal.id,
      :principal_type => principal.class.name, :subject_id => subject.id,
      :subject_type => subject.class.name }   
  end
end
