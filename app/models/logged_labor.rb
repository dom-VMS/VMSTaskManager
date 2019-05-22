class LoggedLabor < ApplicationRecord
  ## Active Record Associations
  belongs_to :task
  belongs_to :user

  ## Scopes
  scope :for_task, -> (task){ where(task_id: task) }

  ## Active Record Validations
  validates :time_spent, numericality: { message: "must be a number." }
  validates :labor_date, presence: true

  # Calculates total amount of time spent on a task.
  def self.hours_spent_on_task(task)
    time_spent = LoggedLabor.for_task(task).pluck(:time_spent)
    calculatedTime = (time_spent).sum.to_f
  end

end
