class AdminController < ApplicationController
    def index
    end

    def task_types
        @task_type = TaskType.all
    end
end
