class TaskTypeOptionsController < ApplicationController
    def index
        @task_type = TaskType.all
        @task_type_options = @task_type.task_type_options.all
    end

    def show
        @task_type = TaskType.find(params[:task_type_id])
        @task_type_option = @task_type.task_type_options.find_by_id(params[:id])


        #@user_group = UserGroup.find_by_task_type_option_id(@task_type_option)
        #userID = @user_group.users_id
        #@user = User.find_by_id(userID)



    end

    def new
        @task_type = TaskType.find(params[:task_type_id])
        @task_type_option = @task_type.task_type_options.new
    end

    def create
        @task_type = TaskType.find(params[:task_type_id])
        @task_type_option = @task_type.task_type_options.new(task_type_options_params)

        if @task_type_option.save
            redirect_to task_types_path
        else
            render 'new'
        end
    end

    def edit
        @task_type_option = TaskTypeOption.find(params[:id])
        @task_type = TaskType.find(params[:task_type_id])
    end

    def update
        @task_type = TaskType.find(params[:task_type_id])
        @task_type_option = @task_type.task_type_options.find_by_id(params[:id])

        if @task_type_option.update(task_type_options_params)
            redirect_to task_types_path
        else
            render 'edit'
        end
    end

    def destroy
        @task_type = TaskType.find(params[:task_type_id])
        @task_type_option = @task_type.task_type_options.find(params[:id])
        @task_type_option.destroy

        redirect_to task_types_path
    end

    private
    def task_type_options_params
      params.require(:task_type_option).permit(:name,
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
