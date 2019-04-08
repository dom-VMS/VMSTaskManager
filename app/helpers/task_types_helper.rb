module TaskTypesHelper

    # Returns a link to a user's TaskTypeOption based on a given TaskType.
    def user_task_type_option(user)
        tto = TaskTypeOption.get_task_type_specific_options(user, @task_type)
        link_to tto.name, task_type_task_type_option_path(tto.task_type, tto) unless tto.nil?
    end

    # This method recursively returns an array of TaskTypes in the order of their parent/child relationship.
    # The order in-which these TaskTypes returned is in reverse, so this should be called as follows:
    # project_hierarchy(@task_type).reverse
    def project_hierarchy(task_type)
        list = [task_type]
        if task_type.parent.present?
            list += project_hierarchy(task_type.parent)
        end
        list
    end

end
