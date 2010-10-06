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

  # Virtual field that we use so we don't expose principal_id.
  def principal_name=(new_principal_name)
    @principal_name = new_principal_name
    if principal_type
      self.principal = Object.const_get(principal_type).
                              find_by_name(new_principal_name)
    else
      self.principal_id = nil
    end
  end
  def principal_name
    @principal_name ||= principal && principal.name
  end
  
  # Sets principal_id if principal_name= is called before principal_type=.
  def principal_type=(new_principal_type)
    super
    if @principal_name && !principal_id
      principal = Object.const_get(principal_type).find_by_name(@principal_name)
      self.principal_id = principal && principal.id
    end
  end
  
  # Use principal (profile / user) names instead of IDs.
  def to_param
    principal_name
  end

  # Sets the principal-subject ACL entry to role. Role can be nil.
  def self.set(principal, subject, role)
    conditions = where_clause principal, subject
    entry = where(conditions).first
    if role
      entry ||= new conditions
      entry.role = role
      entry.save!
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
