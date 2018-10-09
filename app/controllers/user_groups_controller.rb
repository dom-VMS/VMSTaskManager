class UserGroupsController < ApplicationController
    def index
        @user_groups = UserGroup.all
    end

    def show
        @user_group = UserGroup.find(params[:id])
    end

    def new
        @user_group = UserGroup.new
    end

    def edit 
    end

    def create
        @user_group = UserGroup.new(user_group_params)
 
        if @user_group.save!
            redirect_to action: "index"
        else
            render 'new'
        end
    end

    def update
    end

    def destroy
    end

    private
    def user_group_params
        params.require(:user_group).permit(:user_id, :task_type_option_id)
    end
end
