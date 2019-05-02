class ReoccuringTask < ApplicationRecord
    belongs_to :reoccuring_task_type
    belongs_to :task, optional: true, required: false

    validates_presence_of :reoccuring_task_type_id

end
