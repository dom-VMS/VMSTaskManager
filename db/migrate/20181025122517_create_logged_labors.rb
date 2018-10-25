class CreateLoggedLabors < ActiveRecord::Migration[5.1]
  def change
    create_table :logged_labors do |t|
      t.references :task, foreign_key: true
      t.references :user, foreign_key: true
      t.decimal :time_spent
      t.text :description

      t.timestamps
    end
  end
end
