class AddReoccuringEventToTask < ActiveRecord::Migration[5.1]
  def change
    add_reference :tasks, :reoccuring_event, foreign_key: true
  end
end
