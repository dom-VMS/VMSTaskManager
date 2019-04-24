class TaskQueue < ApplicationRecord
  include RailsSortable::Model
  set_sortable :position

  after_destroy :reposition_queue
  
  belongs_to :task
  belongs_to :user
  belongs_to :task_type

  # Once an item is removed from the queue, change the position of items that were 
  def reposition_queue
    task_queue = TaskQueue.where(user_id: user_id, task_type_id: task_type_id)
    if task_queue.pluck(:position).any? {|pos| pos > position}
      task_queue.where("position > ?", position).each do |queue_item|
        queue_item.update(:position => (queue_item.position - 1))
      end
    end
  end

  def self.retrieve_tasks(user, task_type)
    tasks = []
    queue = user.task_queues.where(task_type_id: task_type).order(:position)
    queue.each do |item|
      tasks.push(Task.find_by_id(item.task_id))
    end
  end
end
