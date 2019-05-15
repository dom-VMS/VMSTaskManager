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

    def project_hierarchy_view(task_type, final_html, level)
        if task_type.children.present?
            level = level + 1
            task_type.children.each do |child|
                final_html += (("<ul>" * level) + "#{link_to child.name, task_type_path(child)}" + ("</ul>" * level) + "<br>").html_safe
                final_html = project_hierarchy_view(child, final_html, level) 
            end
        end
        final_html.html_safe
    end
end
