module TasksHelper
    # Takes a task and returns task.priority in a badge.
    def task_badges(task)
        if task.status == 3 && task.isVerified == true
            return ('<span class="badge badge-success">Complete</span>').html_safe
        elsif task.status == 3 && (task.isVerified == nil)
            return ('<span class="badge badge-info">Pending Verification</span>').html_safe
        elsif task.status == 0 && (task.isVerified == false)
            return ('<span class="badge badge-warning">Rework Required</span>').html_safe
        elsif task.status == 4 
            return ('<span class="badge badge-dark">On-Hold</span>').html_safe
        elsif task.priority == 1 
            return ('<span class="badge badge-light">Low</span>').html_safe
        elsif task.priority == 2 
            return ('<span class="badge badge-primary">Normal</span>').html_safe
        elsif task.priority == 3 
            return ('<span class="badge badge-warning">High</span>').html_safe
        elsif task.priority == 4 
            return ('<span class="badge badge-danger">Urgent</span>').html_safe
        else 
            return ""
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
        elsif task.status == 4
            return "On-Hold"
        end
    end

    def task_created_by_name(task)
        if task.created_by_id.nil?
            " "
        else
            User.find_by_id(task.created_by_id).full_name unless User.find_by_id(task.created_by_id).nil?
        end 
    end

    def reoccuring_badge(task)
        if task.status == 3 && task.isVerified == true && task.reoccuring_task.present?
            return ('<span class="badge badge-dark">'+ "#{((task.reoccuring_task.next_date).to_date - Date.today).to_i} days left" +'</span>').html_safe
        end
    end

    def large_task_badges(task)
        if task.isApproved.nil?
            return ('<span class="badge badge-warning">Pending Approval</span>').html_safe
        elsif task.isApproved == false 
            return ('<span class="badge badge-danger">Ticket Denied</span>').html_safe
        end
    end

end
