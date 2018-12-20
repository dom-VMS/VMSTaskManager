class TaskType < ApplicationRecord
    include PublicActivity::Model
    tracked

    has_many :tasks
    has_many :task_type_options

    validates :name, presence: true

    tracked owner: Proc.new{ |controller, model| controller.current_user }

    # Returns all the task_types a user belongs to a user.
    def self.get_task_types_assigned_to_user(current_user)
        tto = current_user.task_type_options
        return nil if tto.empty?

        user_task_types = tto.pluck(:task_type_id)
        return user_task_types
    end
end
