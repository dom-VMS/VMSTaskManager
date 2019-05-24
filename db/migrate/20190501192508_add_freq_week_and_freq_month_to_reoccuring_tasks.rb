class AddFreqWeekAndFreqMonthToReoccuringTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :reoccuring_tasks, :freq_weeks, :integer
    add_column :reoccuring_tasks, :freq_months, :integer
  end
end
