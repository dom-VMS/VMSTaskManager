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
  
  # When a task is verified as complete, this funciton is called to remove the given task from any queue with it present.
  def self.remove_comepleted_task_from_queue(task)
    queue_items = TaskQueue.where(task_id: task.id)
    unless queue_items.nil?
      queue_items.each do |queue_item|
        queue_item.destroy
      end
    end
  end

end
