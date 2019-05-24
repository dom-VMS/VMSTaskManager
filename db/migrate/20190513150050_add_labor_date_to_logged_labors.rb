class AddLaborDateToLoggedLabors < ActiveRecord::Migration[5.2]
  def change
    add_column :logged_labors, :labor_date, :datetime
  end
end
