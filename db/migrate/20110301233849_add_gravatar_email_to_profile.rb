class AddGravatarEmailToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :display_email, :string, :limit => 128, :null => true

    User.all.each do |user|
      user.profile.display_email = user.email
    end
  end
  
  
  def self.down
    remove_column :profiles, :display_email, :string
  end
end
