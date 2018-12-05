module SessionsHelper

    # Logs in the given user.
    def log_in(user)
        session[:user_id] = user.id
    end

    # Returns the current logged-in user (if any).
    def current_user
        if session[:user_id]
            @current_user ||= User.find_by(id: session[:user_id])
        end
    end

    # Returns boolean value for if user is logged in.
    def logged_in?
        !current_user.nil?
    end

    # Logs out the current user
    def log_out
        session.destroy
        @current_user = nil
    end

    # Checks if the user is an Admin in any department
    def isAdmin?
        tto = current_user.task_type_options
        admin = tto.pluck(:isAdmin)
        if admin.include?(true)
            return true
        else
            return false
        end
    end

    # Checks if the user can verify task completion for any department.
    def canVerify?
        tto = current_user.task_type_options
        verify = tto.pluck(:can_verify)
        if verify.include?(true)
            return true
        else
            return false
        end
    end

    # Checks current user if they are an admin in Maintenance (task_type_id == 1)
    # ...
    # Used to determine who can "Review (Approve/Deny) Tickets"
    def isMaintenanceCanApprove?
        maintenance_tto = TaskTypeOption.get_task_type_specific_options(current_user, 1) unless !current_user.present?
        maintenance_tto.nil? ? (return false) : (return maintenance_tto.can_approve?)
    end
end
