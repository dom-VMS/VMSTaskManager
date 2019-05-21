class TaskTypeOptionsController < ApplicationController
    def index
        @task_types = TaskType.all
        @task_type_options = TaskTypeOption.all
    end

    def show
        @task_type_option = TaskTypeOption.find_by_id(params[:id])
        @task_type = TaskType.find_by_id(@task_type_option.task_type_id)
        @current_user_task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type)
    end

    def new
        @task_type = TaskType.find_by_id(params[:task_type_id])
        current_task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type)
        unless @task_type.task_type_options.empty?
            if current_task_type_option.nil?
                flash[:error] = "Sorry, but you do not have permission to create #{@task_type.name} roles."
                redirect_to task_type_path(@task_type)
            else
                @task_type_option = TaskTypeOption.new
            end
        else
            @task_type_option = TaskTypeOption.new
        end
    end

    def create
        @task_type = TaskType.find_by_id(params[:task_type_id])
        @task_type_option = TaskTypeOption.new(task_type_options_params)

        if @task_type_option.save
            redirect_to task_type_task_type_option_path(@task_type, @task_type_option)
        else
            render 'new'
        end
    end
 #=end

    def edit
        @task_type_option = TaskTypeOption.find(params[:id])
        @task_type = TaskType.find_by_id(params[:task_type_id])
    end

    def update
        @task_type = TaskType.find_by_id(params[:task_type_id])
        @task_type_option = TaskTypeOption.find(params[:id])

        if @task_type_option.update(task_type_options_params)
            redirect_to task_type_task_type_option_path(@task_type, @task_type_option)
        else
            render 'edit'
        end
    end
    def destroy
        @task_type_option = TaskTypeOption.find(params[:id])
        @task_type = @task_type_option.task_type
        @task_type_option.destroy

        redirect_to task_type_path(@task_type)
    end

    private
    def task_type_options_params
      params.require(:task_type_option).permit(:name,
                                               :isAdmin,
                                               :can_view,
                                               :can_create,
                                               :can_update,
                                               :can_delete,
                                               :can_approve,
                                               :can_verify,
                                               :can_comment,
                                               :can_log_labor,
                                               :can_view_cost,
                                               :task_type_id)
    end

end
