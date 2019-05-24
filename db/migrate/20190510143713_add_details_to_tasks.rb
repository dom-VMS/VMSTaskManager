class AddDetailsToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :verification_required, :boolean
    add_column :tasks, :logged_labor_required, :boolean
    add_reference :tasks, :completed_by, foreign_key: { to_table: :users }
    add_reference :tasks, :verified_by, foreign_key: { to_table: :users }
  end
end
