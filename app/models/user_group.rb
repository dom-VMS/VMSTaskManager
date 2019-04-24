class UserGroup < ApplicationRecord
    #has_many :through Association (users x user_groups x task_type_options)
    belongs_to :user, optional: true
    belongs_to :task_type_option, optional: true

end
