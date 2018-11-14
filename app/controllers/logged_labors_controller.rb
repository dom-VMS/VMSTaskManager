class LoggedLaborsController < ApplicationController
    def index
        @task = Task.find(params[:task_id])
        @logged_labors = LoggedLabor.where(:task_id => @task.id)
        @hours_spent = LoggedLabor.hours_spent_on_task(@task)
    end

    def show
    end

    def new
        @task = Task.find(params[:task_id])
        @logged_labors = LoggedLabor.new
    end

    def create
        @task = Task.find(params[:task_id])
        @logged_labors = @task.logged_labors.create(logged_labor_params)
        if @logged_labors.valid? 
            flash[:success] = "Labor entry added."
            redirect_to task_path(@task)
        else
            flash[:error] = "Labor Entry Failed!"
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
          params.require(:logged_labor).permit(:user_id, :description, :time_spent, :task_id)
        end
end
