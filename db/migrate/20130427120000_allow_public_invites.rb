class AllowPublicInvites < ActiveRecord::Migration
  def self.up
    change_column :invites, :group_id, :integer, :default => nil, :null => true
    change_column :invites, :user_id, :integer, :default => nil, :null => true
  end

  def self.down
    Invite.delete_all(:group_id => nil)
    Invite.where(:user_id => nil).update_all(:user_id => 0)
    change_column :invites, :group_id, :integer, :default => 0, :null => false
    change_column :invites, :user_id, :integer, :default => 0, :null => false
  end
end
