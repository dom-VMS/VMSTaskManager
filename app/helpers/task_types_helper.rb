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
end
