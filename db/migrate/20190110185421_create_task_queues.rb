class CreateTaskQueues < ActiveRecord::Migration[5.1]
  def change
    create_table :task_queues do |t|
      t.references :task, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
