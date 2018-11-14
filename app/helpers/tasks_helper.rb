module TasksHelper
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

    def task_status(task)
        if task.status == 1
            return "Incomplete"
        elsif task.status == 2
            return "In-Progress"
        elsif task.status == 3
            return "Complete"
        end
    end

    def self.get_activities(task)
        activities_by_trackable = PublicActivity::Activity.order("created_at desc").where("trackable_type = ? and trackable_id = ?", "Task", task.id)
        activities_by_recipient = PublicActivity::Activity.order("created_at desc").where("recipient_type = ? and recipient_id = ?", "Task", task.id)
        return activities = activities_by_trackable + activities_by_recipient
    end
end
