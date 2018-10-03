class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.integer :employee_number
      t.string :f_name
      t.string :l_name
      t.string :email
      t.integer :hourly_rate

      t.timestamps
    end
  end
end
