class UsersController < ApplicationController
  before_action :find_user, only: [:show, :edit, :update]

    def index
      current_user = User.find_by_id(session[:current_user_id])
      @users = User.all.order(:employee_number)
    end

    def show
      unless isAdmin? == true || current_user.id == @user.id
        respond_to do |format|
          flash[:error] = "Sorry, but you are not permitted to access this user's info."
          format.html { redirect_back(fallback_location: users_path) }
        end
      end
      @user_group = @user.user_groups   
      get_task_type_options_from_user_group
      task_type_ids = TaskType.get_task_types_assigned_to_user(@user)
      @task_types = TaskType.where(id: [task_type_ids])
      @task = Task.get_all_tasks_assigned_to_user(@user)
    end
    
    def new
      @user = User.new
    end

    def edit
      @user = User.find(params[:id])
      @user_group = @user.user_groups   
      get_task_type_options_from_user_group
    end

    def create
      @user = User.create(user_params)
      if @user.save!
          flash[:success] = "User Added!"
          redirect_to @user
      else
          render 'new'
      end
    end

    def update
      @user = User.find(params[:id])
      
      if @user.update(edit_user_params)
        redirect_to @user
      else
        render 'edit'
      end
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy
      
      redirect_to users_path
    end

    private
      def user_params
        params.require(:user).permit(:employee_number, :f_name, :l_name, :email, :hourly_rate, :password, :password_confirmation)
      end

      def edit_user_params
        params.require(:user).permit(:employee_number, :f_name, :l_name, :email, :hourly_rate)
      end

      def get_task_type_options_from_user_group
        @user_group.each do |user_group|
            @task_type_option = user_group.task_type_option
        end
      end

    protected
      def find_user
        @user = User.find(params[:id])
      end
end
