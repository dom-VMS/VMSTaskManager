class LoggedLabor < ApplicationRecord
  ## Active Record Associations
  belongs_to :task
  belongs_to :user

  ## Active Record Validations
  validates :time_spent, numericality: { message: "must be a number." }
  validates :labor_date, presence: true

  def self.hours_spent_on_task(task)
    calculatedTime = 0
    (LoggedLabor.where(task_id: task.id)).each do |logged_labor|
      calculatedTime = calculatedTime + logged_labor.time_spent
    end
    return calculatedTime
  end

end
