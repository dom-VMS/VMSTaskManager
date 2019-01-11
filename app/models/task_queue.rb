class TaskQueue < ApplicationRecord
  belongs_to :task
  belongs_to :user

  def self.retrieve_tasks(user)
    tasks = []
    queue = TaskQueue.where(user_id: user.id).order(:position)
    queue.each do |item|
      tasks.push(Task.find_by_id(item.task_id))
    end
    return tasks
  end
end
