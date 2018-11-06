module TaskTypesHelper
    def task_priority(task)
        if task.priority == 1 
            return "Low"
        elsif task.priority == 2 
            return "Normal"
        elsif task.priority == 3 
            return "High"
        elsif task.priority == 4 
            return "Urgent"
        end 
    end

    def task_status(task)
        if task.status == 1
            return "Incomplete"
        elsif task.status == 2
            return "In-Progress"
        elsif task.status == 3
            return "Complete"
        end
    end

    # Returns all tasks assigned to a current user.
    def get_all_tasks_assigned_to_user
        tasks = []
        (TaskAssignment.where("assigned_to_id = #{current_user.id}")).each do |assignment|
            tasks.push(Task.find_by_id(assignment.task_id))
        end

       return tasks
    end

    # Returns all open task(s), associated with a task type, that is assigned to a current user.
    def get_tasks_assigned_to_user_for_task_type(task_type)
        tasks = []
        (TaskAssignment.where("assigned_to_id = #{current_user.id}")).each do |assignment|
            if ((Task.find_by_id(assignment.task_id)).task_type_id == task_type.id) && ((Task.find_by_id(assignment.task_id)).status != 3)
                tasks.push(Task.find_by_id(assignment.task_id))
            end
        end
        
        return tasks
    end
end
