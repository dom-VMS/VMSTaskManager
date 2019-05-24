module SessionsHelper

    # Logs in the given user.
    def log_in(user)
        session[:user_id] = user.id
    end

    # Remembers a user in a persistent session.
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    # Returns the current logged-in user (if any).
    def current_user
        if (user_id = session[:user_id])
            @current_user ||= User.find_by(id: session[:user_id])
        elsif (user_id = cookies.signed[:user_id])
            user = User.find_by(id: user_id)
            if user && user.authenticated?(cookies[:remember_token])
              log_in user
              @current_user = user
            end
        end
    end

    # Forgets a persistent session.
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # Returns boolean value for if user is logged in.
    def logged_in?
        !current_user.nil?
    end

    # Logs out the current user
    def log_out
        forget(current_user)
        session.destroy
        @current_user = nil
    end

    # Checks if the user is an Admin in any department
    def isAdmin?
        current_user.task_type_options.where(isAdmin: true).present? ? true : false
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
