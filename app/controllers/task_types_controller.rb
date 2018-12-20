class TaskTypesController < ApplicationController
    def index
        @task_type = TaskType.all
    end
    
    def show
        @task_type = find_task_type
        @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type.id)
        @tasks = @task_type.tasks.where.not(status: 3).or(@task_type.tasks.where(status: nil).where(isApproved: true)).order("created_at DESC")
        @tasks_assigned_to_user = Task.get_tasks_assigned_to_user_for_task_type(@task_type, current_user)
        @tasks_recently_complete = @task_type.tasks.where('status = 3').where("updated_at > ?", 14.days.ago)
    end
    
    def new
        @task_type = TaskType.new
    end

    def edit
        @task_type = find_task_type
        task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type.id)
        if task_type_option.nil?
            flash[:error] = "Sorry, but you do not have permission to edit #{@task_type.name}."
            redirect_to admin_task_types_path
        end
    end

    def create
        @task_type = TaskType.new(task_type_params)
 
        if @task_type.save
            flash[:success] = "#{@task_type.name} has been added!"
            redirect_to @task_type
        else
            flash[:danger] = "Oops! Something went wrong."
            render 'new'
        end
    end

    def update
        @task_type = find_task_type
       
        if @task_type.update(task_type_params)
          flash[:success] = "#{@task_type.name} has been updated!"
          redirect_to '/admin/task_types'
        else
          flash[:danger] = "Oops! Something went wrong. #{@task_type.name} wasn't updated. "
          render 'edit'
        end
    end

    private
      def task_type_params
        params.require(:task_type).permit(:task_type_id, :name, :description)
      end

      def find_task_type
        TaskType.find(params[:id])
      end
end
