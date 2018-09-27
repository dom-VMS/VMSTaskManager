class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.integer :priority
      t.integer :status
      t.integer :percentComplete

      t.timestamps
    end
  end
end
