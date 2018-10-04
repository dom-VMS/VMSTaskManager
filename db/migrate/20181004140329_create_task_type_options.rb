class CreateTaskTypeOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :task_type_options do |t|
      t.string :name
      t.boolean :can_view
      t.boolean :can_create
      t.boolean :can_update
      t.boolean :can_delete
      t.boolean :can_approve
      t.boolean :can_verify
      t.boolean :can_comment
      t.boolean :can_log_labor
      t.boolean :can_view_cost
      t.references :task_type, foreign_key: true

      t.timestamps
    end
  end
end
