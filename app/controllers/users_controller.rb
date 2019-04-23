class UsersController < ApplicationController
  before_action :find_user, only: [:show, :edit, :update]

    def index
      current_user = User.find_by_id(session[:current_user_id])
      if search_params[:search]
        @users = User.search(search_params[:search])
        if @users.nil? || @users.empty?
          @users = User.all.order(:employee_number)
          flash[:notice] = "Sorry, we couldn't find what you are searching for."
        end
      else
        @users = User.all.order(:employee_number)
      end

    end

    def show
      @can_edit = verify_if_current_user_can_edit(@user, current_user)
      @user_group = @user.user_groups   
      get_task_type_options_from_user_group
      task_type_ids = TaskType.get_task_types_assigned_to_user(current_user)
      task_types = TaskType.where(id: [task_type_ids])
      @task_types = []
      task_types.each do |task_type|
        @task_types += TaskType.get_list_of_assignable_projects(task_type)
      end
      @task = Task.get_all_tasks_assigned_to_user(@user)
      @pagy_recent_activity, @recent_activity = pagy(@user.logged_labors.order('created_at DESC'), page_param: :page_recent_activity, params: { active_tab: 'recent_activity' })
    end
    
    def new
      @user = User.new
    end

    def edit
      @user = User.find(params[:id])
      unless verify_if_current_user_can_edit(@user, current_user)
        respond_to do |format|
          #flash[:error] = "You are not permitted to edit this user's info."
          format.html { redirect_to user_path(@user) }
        end
      end
      @user_group = @user.user_groups   
      get_task_type_options_from_user_group
    end

    def create
      @user = User.new(user_params)
 
      respond_to do |format|
        if @user.save
          # Tell the UserMailer to send a welcome email after save
          UserMailer.with(user: @user).welcome_email.deliver_now #deliver_now!
  
          format.html { redirect_to(@user, notice: 'User was successfully created.') }
          format.json { render json: @user, status: :created, location: @user }
        else
          format.html { render action: 'new' }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end

    def update
      @user = User.find(params[:id])
      unless verify_if_current_user_can_edit(@user, current_user)
        respond_to do |format|
          flash[:error] = "You are not permitted to update this user's info."
          format.html { redirect_to user_path(@user) }
        end
      end
      
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

      def search_params
        params.permit(:search)
      end

      def get_task_type_options_from_user_group
        @user_group.each do |user_group|
            @task_type_option = user_group.task_type_option
        end
      end

    protected
      # Grabs user based on id
      def find_user
        @user = User.find(params[:id])
      end

      # Verifies if the current_user may edit a given @user information
      def verify_if_current_user_can_edit(user, current_user)
        return true if (current_user == user) # If current_user is @user, they may edit @user.
        return false if current_user&.task_type_options.nil? #If current_user has no roles, they may not edit @user.
        if isAdmin?
          task_types = current_user.task_type_options.where(isAdmin: true).pluck(:task_type_id)
          task_types.each do |current_user_task_type| #Return true if any task_types current_user is an admin for.
            return true if (user.task_type_options.pluck(:task_type_id).any? {|user_task_type| user_task_type == current_user_task_type})
          end
        end
        return false #If all tests fail, return false.
      end
end
