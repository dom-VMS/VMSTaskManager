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
        return current_user.task_type_options.pluck(:isAdmin).any? == true
    end

    # Checks if the current user can verify task completion for any department.
    def canVerify?
        return current_user.task_type_options.pluck(:can_verify).any? == true
    end

    # Checks if the current user can approve tickets for any department.
    def canApprove?
        return current_user.task_type_options.pluck(:can_approve).any? == true
    end
end
