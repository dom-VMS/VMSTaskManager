module TaskTypesHelper
    def user_task_type_option(user)
        tto = TaskTypeOption.get_task_type_specific_options(user, @task_type.id)
        link_to tto.name, task_type_option_path(tto) unless tto.nil?
    end
end
