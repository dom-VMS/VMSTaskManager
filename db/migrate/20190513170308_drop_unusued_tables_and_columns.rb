class DropUnusuedTablesAndColumns < ActiveRecord::Migration[5.2]
  def change
    #remove_column :tasks, :reoccuring_event_id
    remove_column :reoccuring_events, :reoccuring_event_type_id
    drop_table :reoccuring_event_types
    drop_table :reoccuring_events
  end
end
