class UserGroup < ApplicationRecord
  has_and_belongs_to_many :users
  has_and_belongs_to_many :task_type_options
end
