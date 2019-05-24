class ReoccuringTaskTypesController < ApplicationController
    def index
        @reoccuring_task_types = ReoccuringTaskTypes.all
    end
end
