class SessionsController < ApplicationController
    def new
    end

    def create
        user = User.find_by(employee_number: params[:session][:employee_number])
        if user && user.authenticate(params[:session][:password])
            #Log the user in and redirect to home.
            log_in user
            redirect_to home_index_path
        else
            #Create an error message
            flash[:danger] = 'Invalid employee #/password combination'
            render 'new'
        end
    end

    def destroy
        log_out if logged_in?
        reset_session
        redirect_to root_path
    end

end
