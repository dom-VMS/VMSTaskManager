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

    # Checks if the current user can verify task completion for any department.
    def canVerify?
        tto = current_user.task_type_options
        verify = tto.pluck(:can_verify)
        if verify.include?(true)
            return true
        else
            return false
        end
    end

    # Checks if the current user can approve tickets for any department.
    def canApprove?
        tto = current_user.task_type_options
        approve = tto.pluck(:can_approve)
        if approve.include?(true)
            return true
        else
            return false
        end
    end
end
