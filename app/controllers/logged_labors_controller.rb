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
        puts "\n\ncurrent_task_type_option: #{current_task_type_option.to_json}\n\n"
        if current_task_type_option.nil? || current_task_type_option.can_log_labor == false
            flash[:error] = "Sorry, but you do not have permission to log time for Task ##{@task.id}"
            redirect_to task_path(@task)
        else
            @logged_labor = LoggedLabor.new  
        end 
    end

    def create
        @task = Task.find(params[:task_id])
        @logged_labor = @task.logged_labors.create(logged_labor_params)
        if @logged_labor.valid? 
            flash[:success] = "Labor entry added."
            redirect_to task_path(@task)
        else
            flash[:error] = "Labor entry failed."
            render 'new'
        end
        
    end

    def edit
        @task = Task.find(params[:task_id])
        task_type = @task.task_type
        @logged_labor = LoggedLabor.find_by_id(params[:id])
        current_task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, task_type)
        if current_task_type_option.nil? || current_user.id != @logged_labor.user_id
            flash[:error] = "Sorry, but you do not have permission to log time for Task ##{@task.id}"
            redirect_to task_path(@task)
        end
    end
    
    def update
        @task = @task = Task.find(params[:task_id])
        @logged_labor = LoggedLabor.find_by_id(params[:id])
        if @logged_labor.update(logged_labor_params)
            flash[:success] = "Labor entry updated."
            redirect_to @task
        else
            flash[:error] = "Update failed."
          render 'edit'
        end
    end

    def destroy
    end

    private
        def logged_labor_params
          params.require(:logged_labor).permit(:user_id, :description, :time_spent, :task_id, :labor_date)
        end
end
