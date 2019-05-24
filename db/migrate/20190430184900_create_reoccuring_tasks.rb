class CreateReoccuringTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :reoccuring_tasks do |t|
      t.references :reoccuring_task_type, index: true, foreign_key: true
      t.references :task, index: true, foreign_key: true
      t.integer :freq_days
      t.datetime :last_date
      t.datetime :next_date
      

      t.timestamps
    end
  end
end
