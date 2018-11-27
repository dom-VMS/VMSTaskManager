module TasksHelper
    # Takes a task and returns task.priority in a badge.
    def task_priority(task)
        if task.priority == 1 
            return ('<span class="badge badge-light">Low</span>').html_safe
        elsif task.priority == 2 
            return ('<span class="badge badge-primary">Normal</span>').html_safe
        elsif task.priority == 3 
            return ('<span class="badge badge-warning">High</span>').html_safe
        elsif task.priority == 4 
            return ('<span class="badge badge-danger">Urgent</span>').html_safe
        end 
    end

    # Takes a task and returns task.status in readable text.
    def task_status(task)
        if task.status == 1
            return "Incomplete"
        elsif task.status == 2
            return "In-Progress"
        elsif task.status == 3
            return "Complete"
        end
    end

end
