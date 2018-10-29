class TaskTypesController < ApplicationController
    def index
        @task_type = TaskType.all
    end
    
    def show
        @task_type = TaskType.find(params[:id])
    end
    
    def new
        @task_type = TaskType.new
    end

    def edit
        @task_type = TaskType.find(params[:id])
    end

    def create
        @task_type = TaskType.new(task_type_params)
 
        if @task_type.save
            redirect_to @task_type
        else
            render 'new'
        end
    end

    def update
        @task_type = TaskType.find(params[:id])
       
        if @task_type.update(task_type_params)
          redirect_to @task_type
        else
          render 'edit'
        end
    end

    private
      def task_type_params
        params.require(:task_type).permit(:task_type_id, :name, :description)
      end
end
