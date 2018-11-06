class AdminController < ApplicationController
    def index
        if logged_in?
            unless isAdmin?
                redirect_to home_index_path
            end
        else
            render partial: 'errors/not_signed_in'
        end
    end

    def task_types
        @task_type = TaskType.all
    end
end
