class UserGroupsController < ApplicationController
    def index
        @user = User.find_by_id(params[:user_id])
        @user_group = UserGroup.where(users_id: @user.id).all
        if !@user_group.empty?
            @task_type_option = TaskTypeOption.find_by_user_group(@user_group)
        end
    end

    def show
        @user_group = UserGroup.find(params[:id])
    end

    def new
        @task_type_option = TaskTypeOption.find_by_id(params[:task_type_option_id])
        @user_group = UserGroup.new
    end

    def edit
    end

    def create
        @task_type_option = TaskTypeOption.find_by_id(params[:task_type_option_id])
        @user_group = UserGroup.new(user_group_params)

        if @user_group.save!
            redirect_to admin_path
        else
            render 'new'
        end
    end

    def update 
    end

    def destroy
        @user_group = UserGroup.find(params[:id])
        @user_group.destroy

        redirect_to users_path
    end

    private 
    def user_group_params
        params.require(:user_group).permit(:users_id, :task_type_option_id)
    end
end
