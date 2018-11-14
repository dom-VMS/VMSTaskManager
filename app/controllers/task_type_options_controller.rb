class TaskTypeOptionsController < ApplicationController
    def index
        @task_type_options = TaskTypeOption.all
    end

    def show
        @task_type_option = TaskTypeOption.find(params[:id])
        @task_type_name = (TaskType.find_by_id(@task_type_option.task_type_id)).name
        @user = TaskTypeOption.get_associated_users(@task_type_option)
    end

    def new
        @task_type = TaskType.find_by_id(params[:task_type])
        @task_type_option = TaskTypeOption.new
    end

    def create
        @task_type_option = TaskTypeOption.new(task_type_options_params)

        if @task_type_option.save
            redirect_to @task_type_option
        else
            render 'new'
        end
    end

    def edit
        @task_type_option = TaskTypeOption.find(params[:id])
        @task_type = TaskType.find_by_id(@task_type_option.task_type_id)
    end

    def update
        @task_type_option = TaskTypeOption.find(params[:id])

        if @task_type_option.update(task_type_options_params)
            redirect_to @task_type_option
        else
            render 'edit'
        end
    end

    def destroy
        @task_type_option = TaskTypeOption.find(params[:id])
        @task_type_option.destroy

        redirect_to task_type_options_path
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
