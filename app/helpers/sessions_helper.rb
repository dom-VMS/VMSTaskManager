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

    # Checks if the task_type_option is an Admin
    def isAdmin?
        tto = current_user.task_type_options
        container = tto.pluck(:isAdmin)
        if container.include?(true)
            return true
        else
            return false
        end
    end
end
