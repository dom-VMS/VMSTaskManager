class LoggedLaborsController < ApplicationController
    def index
        @task = Task.find(params[:task_id])
        @logged_labors = LoggedLabor.where(task_id:  @task.id).order('updated_at DESC')
        @hours_spent = LoggedLabor.hours_spent_on_task(@task)
    end

    def show
    end

    def new
        @task = Task.find(params[:task_id])
        task_type = @task.task_type
        current_task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, task_type)
        if current_task_type_option.nil?
            flash[:error] = "Sorry, but you do not have permission to log time for Task ##{@task.id}"
            redirect_to task_path(@task)
        else
            @logged_labors = LoggedLabor.new  
        end 
    end

    def create
        @task = Task.find(params[:task_id])
        @logged_labors = @task.logged_labors.create(logged_labor_params)
        if @logged_labors.valid? 
            flash[:success] = "Labor entry added."
            redirect_to task_path(@task)
        else
            flash[:error] = "Labor entry failed."
            render 'new'
        end
        
    end

    def edit
    end
    
    def update
    end

    def destroy
    end

    private
        def logged_labor_params
          params.require(:logged_labor).permit(:user_id, :description, :time_spent, :task_id, :updated_at)
        end
end
