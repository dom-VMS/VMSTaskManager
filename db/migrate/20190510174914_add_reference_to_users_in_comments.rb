class AddReferenceToUsersInComments < ActiveRecord::Migration[5.2]
  def change
    remove_column :comments, :commenter
    add_reference :comments, :commenter, foreign_key: { to_table: :users }
  end
end
