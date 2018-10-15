class TaskTypeOption < ApplicationRecord
  belongs_to :task_type
  has_many :users, through: :user_groups
end
