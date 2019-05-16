class UserGroup < ApplicationRecord
    ## Active Record Associations
    # has_many :through Association (users x user_groups x task_type_options)
    belongs_to :user, optional: true
    belongs_to :task_type_option, optional: true

    ## Active Record Validation
    validate :manager_cannot_be_assigned_as_member_for_child_project

    # A manager from a parent project cannot be assigned as a member in a related child project
    def manager_cannot_be_assigned_as_member_for_child_project
        task_type_option = TaskTypeOption.find_by_id(task_type_option_id)
        if task_type_option.isAdmin == false
            user = User.find_by_id(user_id)
            user_task_type_options = user.task_type_options.where(isAdmin: true)
            if user_task_type_options.present? 
                task_type = task_type_option.task_type
                while task_type.parent.present?
                    if user_task_type_options.any?{|utto| utto.task_type_id == task_type.parent.id }
                        errors.add(:user, "cannot be demoted from admin in a sub-project.") 
                    end
                    task_type = task_type.parent
                end
                errors.add(:user, "cannot be demoted from admin in the same project.") if user_task_type_options.any?{|utto| utto.task_type_id == task_type.id}
            end
        end
   
    end
end
