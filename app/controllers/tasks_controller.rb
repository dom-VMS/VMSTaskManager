class TasksController < ApplicationController
    def index
        @tasks = Task.all
    end
    
    def show
        @task = Task.find(params[:id])
    end
    
    def new
        @task = Task.new
    end

    def edit
        @task = Task.find(params[:id])
    end

    def create
        @task = Task.new(new_task_params)
 
        if @task.save!
            redirect_to @task
        else
            render 'new'
        end

    end

    def update
        @task = Task.find(params[:id])
       
        if @task.update(edit_task_params)
            
          redirect_to @task
        else
          render 'edit'
        end
    end

    def destroy
        @task = Task.find(params[:id])
        @task.destroy
       
        redirect_to tasks_path
    end

    private
      def new_task_params
        params.require(:task).permit(:title, :description, :priority, :status, :percentComplete, :task_types_id)
      end

      def edit_task_params
        params.require(:task).permit(:title, :description, :priority, :status, :percentComplete)
      end
end
