class AddIsVerifiedToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :isVerified, :boolean
  end
end
