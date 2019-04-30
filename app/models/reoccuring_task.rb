class ReoccuringTask < ApplicationRecord
    belongs_to :reoccuring_task_type
    belongs_to :task

end
