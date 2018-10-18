module UserGroupsHelper

    # Runs a process to find the name of the role(s) associated with a particular user.
    # Params:
    # user_group - An instance of @user_group associated with a particular @user.
    # task_type_option - An instance of @task_type_option associated with a particular @user.
    def role(user_group, task_type_option)
        role = []
        if user_group.nil? 
            return 'No roles/permissions assigned to this user.'
        else
            role.push(task_type_option.name)

            return role.join.html_safe
        end
    end

end
