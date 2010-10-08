# Someone is allowed to perform an operation on an object in the system.
class AclEntry < ActiveRecord::Base
  # The object that an operation is performed on.
  belongs_to :subject, :polymorphic => true
  validates :subject, :presence => true
  attr_protected :subject_id, :subject_type
  
  # The entity that is allowed to perform the operation.
  belongs_to :principal, :polymorphic => true
  validates :principal, :presence => true
  attr_protected :principal_id, :principal_type
  
  # The type of operation that the subject is allowed to perform.
  validates :role, :presence => true, :length => 1..16
  
  validates :principal_id, :uniqueness => {:scope => [:principal_type, 
      :subject_id, :subject_type]}

  # Virtual field that we use so we don't expose principal_id.
  def principal_name=(new_principal_name)
    @principal_name = new_principal_name
    if principal_type.blank?
      self.principal_id = nil
    else
      self.principal = Object.const_get(principal_type).
                              find_by_name(new_principal_name)
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
    entry = self.for(principal, subject)
    if role
      unless entry
        entry = new
        entry.principal = principal
        entry.subject = subject
      end
      entry.role = role
      entry.save!
    else
      entry.destroy if entry
    end
  end
  
  # The role in a principal-subject ACL entry. Nil if there is no entry.
  def self.get(principal, subject)
    entry = self.for(principal, subject)
    entry && entry.role.to_sym
  end
  
  # The ACL entry between a principal and a subject. Nil if there is no entry.
  def self.for(principal, subject)
    where(:principal_id => principal.id,
          :principal_type => principal.class.name, :subject_id => subject.id,
          :subject_type => subject.class.name).first
  end
end
