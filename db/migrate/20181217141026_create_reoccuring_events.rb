class CreateReoccuringEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :reoccuring_events do |t|
      t.integer :freq_days
      t.date :last_date
      t.date :next_date
      t.references :task, foreign_key: true
      t.references :reoccuring_event_type, foreign_key: true

      t.timestamps
    end
  end
end
