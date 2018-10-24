class UserGroup < ApplicationRecord
    belongs_to :user, optional: true
    belongs_to :task_type_option, optional: true

end
