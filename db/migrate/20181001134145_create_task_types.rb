class CreateTaskTypes < ActiveRecord::Migration[5.1]
  def change
begin
    create_table :task_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end

    add_reference :tasks, :task_types, index: true
    add_foreign_key :tasks, :task_types
end
  end
end
