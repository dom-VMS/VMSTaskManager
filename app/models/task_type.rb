class TaskType < ApplicationRecord
    include PublicActivity::Model
    tracked

    has_many :tasks
    has_many :task_type_options

    validates :name, presence: true

    tracked owner: Proc.new{ |controller, model| controller.current_user }
end
