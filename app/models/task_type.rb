class TaskType < ApplicationRecord
    has_many :tasks
    has_many :task_type_options
end
