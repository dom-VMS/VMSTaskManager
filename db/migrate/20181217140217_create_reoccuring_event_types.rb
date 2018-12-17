class CreateReoccuringEventTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :reoccuring_event_types do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
