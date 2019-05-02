class ReoccuringTasksController < ApplicationController
    def index
        @reoccuring_tasks = ReoccuringTasks.all
    end
end
