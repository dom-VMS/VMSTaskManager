class ChangePrecisionAndScaleOfTimeSpent < ActiveRecord::Migration[5.1]
  def self.up
    change_column :logged_labors, :time_spent, :decimal, :precision => 10, :scale => 2
  end
end
