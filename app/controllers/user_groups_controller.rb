class UserGroupsController < ApplicationController

    def new
        @task_type = TaskType.find_by_id(params[:task_type_id])
        @task_type_option = TaskTypeOption.find_by_id(params[:task_type_option_id])
        @user_group = UserGroup.new
    end

    def create
        @task_type_option = TaskTypeOption.find_by_id(params[:task_type_option_id])
        @task_type = @task_type_option.task_type
        @user_group = UserGroup.create(user_group_params)
        if @user_group.valid?
            redirect_to task_type_task_type_option_path(@task_type, @user_group.task_type_option)
        else
            @user_group.errors.full_messages.each do |msg|
                flash.now[:error] = "#{msg}"
            end
            render 'new'
        end
    end

    def update 
    end

    def destroy
        @user_group = UserGroup.find(params[:id])
        @user_group.destroy

        redirect_back(fallback_location: home_path)
    end

    private 
    def user_group_params
        params.require(:user_group).permit(:user_id, :task_type_option_id)
    end

    protected
    def find_user
        @user = User.find_by_id(params[:user_id])
    end
end
