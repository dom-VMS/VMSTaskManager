class AdminController < ApplicationController
    def index
        unless isAdmin?
            redirect_to home_index_path
        end

    end

    def task_types
        @task_type = TaskType.all
    end
end
