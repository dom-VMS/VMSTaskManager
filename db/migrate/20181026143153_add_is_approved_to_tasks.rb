class AddIsApprovedToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :isApproved, :boolean
  end
end
