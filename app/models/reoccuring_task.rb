class ReoccuringTask < ApplicationRecord
    belongs_to :reoccuring_task_type
    belongs_to :task, optional: true, required: false

    validates_presence_of :reoccuring_task_type_id
    #validates :freq_days, :freq_weeks, :freq_months,  numericality: { only_integer: true }, allow_nil: true

    # When a task's completion is verified, run this process to update:
    # @task.reoccuring_task.last_date 
    # @task.reoccuring_task.next_date 
    # @task.due_date
    def self.update_dates_for_completed_tasks(task)
        reoccuring_task = task.reoccuring_task
        reoccuring_task.last_date = Time.now
        reoccuring_task.next_date = reoccuring_task.last_date + (reoccuring_task.freq_months.nil? ? 0 : reoccuring_task.freq_months.month) + 
                                    (reoccuring_task.freq_weeks.nil? ? 0 : reoccuring_task.freq_weeks.week) + 
                                    (reoccuring_task.freq_days.nil? ? 0 : reoccuring_task.freq_days.day)
        reoccuring_task.save

        task.due_date = reoccuring_task.next_date
        task.save
    end

end
