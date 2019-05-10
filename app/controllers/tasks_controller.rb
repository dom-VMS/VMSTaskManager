class TasksController < ApplicationController
  skip_before_action :require_login, only: [:ticket, :create]
  before_action :all_tasks, only: [:update]
  before_action :find_task, only: [:show, :edit, :update, :destroy]
  before_action :find_task_type, only: [:show, :edit, :update, :new]
  before_action :get_current_user_task_type_options, only: [:show, :new, :edit, :update]

  def show
    @activities = ActivitiesHelper.get_activities(@task)
    @assignees = @task.users
    get_assignable_users        
  end
  
  def new
    if @task_type_option.nil? # Check if user has the proper permissions to create a task for the given project.
        flash[:error] = "Sorry, but you do not have permission to create #{@task_type.name} task."
        redirect_to  task_type_path(@task_type)
    else
        @task = @task_type.tasks.build
        @task_assignment = @task.task_assignments.build
        get_assignable_users        
    end 
  end

  def edit
    validate_current_user # Check if user has the proper permissions to edit a task for the given project.
    @assignees = @task.users
    get_assignable_users
    @assignable_projects = TaskType.get_assignable_projects(@task_type)
  end

  def create
    params = task_params 
    if logged_in?
      @task = Task.new(params)
      @task_type = @task.task_type
      get_current_user_task_type_options
      get_assignable_users
      Task.add_file_attachment(@task, attachment_params[:attachments]) unless attachment_params.empty?
      if @task.save
        if @task.isApproved.nil? #Send email if Ticket is created.
          Task.send_ticket_email(@task, current_user.id)
        end
        flash[:notice] = "Successfully created task."
        redirect_to task_path(@task)
      else
        flash[:error] = "Task creation failed. "
        render 'new'
      end  
    else 
      task_creation_for_not_signed_in_user(params)
    end
  end

  def update
    task_parameters = task_params
    get_assignable_users
    Task.add_file_attachment(@task, attachment_params[:attachments]) unless attachment_params.empty?
    unless params[:isReoccurring]
      reoccuring_task = @task.reoccuring_task
      reoccuring_task.destroy unless reoccuring_task.nil?
      task_parameters = task_params.except :reoccuring_task_attributes
    end
    if @task.update(task_parameters)
        flash[:notice] = "Task updated!"
        respond_to do |format|
            format.html { redirect_to @task }
        end
    else
        flash[:alert] = "Something went wrong." 
        respond_to do |format|
            format.html { render :edit } 
        end      
    end
  end
  
  def destroy
    @task.destroy
    flash[:notice] = "Successfully deleted Task ##{@task.id}" 
    redirect_to task_type_path(@task.task_type_id)
  end

  def ticket
    @task = Task.new
    @task_type = TaskType.where(parent_id: nil)
    @task_assignment = @task.task_assignments.build
  end

  def review # Tickets
    @task_types = TaskType.find(current_user.task_type_options.where(can_approve: true).pluck(:task_type_id))
    unpermitted_task_types = TaskType.find(current_user.task_type_options.where(can_approve: false).pluck(:task_type_id))
    @task_types.each do |task_type|
      if task_type.children.any?
        task_type.children.each do |child|
          @task_types.append(child) unless ((@task_types.any? {|task_type| task_type == child}) || (unpermitted_task_types.any? {|unpermitted| unpermitted == child}))
        end
      end
    end  
    @task = Task.where(isApproved: [nil]).where(task_type_id: [@task_types]).order("updated_at DESC")
  end

  def verify
    @task_types = TaskType.find(current_user.task_type_options.where(can_verify: true).pluck(:task_type_id))
    unpermitted_task_types = TaskType.find(current_user.task_type_options.where(can_verify: false).pluck(:task_type_id))
    @task_types.each do |task_type|
      if task_type.children.any?
        task_type.children.each do |child|
          @task_types.append(child) unless ((@task_types.any? {|task_type| task_type == child}) || (unpermitted_task_types.any? {|unpermitted| unpermitted == child}))
        end
      end
    end  
    @task = Task.where(verification_required: true).where(isVerified: [nil, false]).where(status: 3).where(task_type_id: [@task_types]).order("updated_at DESC")
  end

  def update_ticket
    task = Task.find_by_id(task_params[:id])
    if task.update(task_params) 
        if (task_params[:isApproved] == "true") #Approving a Ticket
            flash[:notice] = "Ticket Approved! You can now add more information to the task and/or assign someone to this."
            TaskMailer.with(task: task).ticket_approved.deliver_later
            redirect_to edit_task_path(task)
        elsif (task_params[:isApproved] == "false") #Declining a Ticket
            Task.insert_decline_feedback(task, decline_feedback_params, attachment_params)
            flash[:notice] = "Ticket Rejected."
            TaskMailer.with(task: task, rejected_by: decline_feedback_params[:commenter_id], feedback: decline_feedback_params[:body]).ticket_rejected.deliver_later
            redirect_back fallback_location: review_path
        elsif (task_params[:isVerified] == "true") #Verifying Task Completion
            ReoccuringTask.update_dates_for_completed_tasks(task) unless task.reoccuring_task.nil?
            flash[:notice] = "Task Completion Approved."
            redirect_back fallback_location: verify_path
            TaskQueue.remove_comepleted_task_from_queue(task)
        elsif (task_params[:isVerified] == "false") #Declining Task Completion
            Task.insert_decline_feedback(task, decline_feedback_params, attachment_params)
            flash[:notice] = "Task Completion Rejected."
            redirect_back fallback_location: verify_path
        else
            flash[:notice] = "Something went wrong"
            redirect_back fallback_location: home_path
        end
    else
      render 'edit'
    end
  end

  private
    def task_params
      params.require(:task).permit(:id, :title, :description, :due_date, :priority, :status, :percentComplete,  :isApproved, :isVerified, :verification_required, :logged_labor_required, :completed_by_id, :verified_by_id, :task_type_id, :created_by_id, task_assignments_attributes:[:id, :assigned_to_id, :assigned_by_id], reoccuring_task_attributes:[:id, :reoccuring_task_type_id, :freq_days, :freq_weeks, :freq_months, :last_date])
    end

    def attachment_params
      params.require(:task).permit({attachments: []})
    end

    def decline_feedback_params
      params.require(:task).permit(:commenter_id, :body)
    end
  
  protected
    # Retrieves all tasks a user is permitted to work on.
    def all_tasks
      @task = Task.get_all_tasks_user_can_see(current_user)
    end 

    # Retrieves a task by its id
    def find_task
      @task = Task.find(params[:id])
    end

    # Finds task_type by task_type_id (used when creating a new task)
    def find_task_type
      unless @task.nil?
        @task_type = @task.task_type
      else
        @task_type = TaskType.find_by_id(params[:task_type_id]) 
      end
    end

    # Gets the current user's Task_Type_Options
    def get_current_user_task_type_options
      @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type) unless !current_user.present?
    end

    # Retrieves all users that may be assigned to a task.
    def get_assignable_users
      @assignable_users = TaskType.get_users(@task_type) 
    end

    # Looks at current user's TaskTypeOptions. Determines if they are permitted to view/edit data.
    def validate_current_user 
      unless @task_type_option&.can_update
        respond_to do |format|
          flash[:error] = "Sorry, but you are not permitted to edit this task."
          format.html { redirect_back(fallback_location: task_path(@task)) }
        end
      end
    end

    # A user may file a ticket (i.e. Create a task) while not being signed in.
    # This function finds the user based on their employee_number, validates the data,
    # and either creates the task or sends the user back with an error message.
    def task_creation_for_not_signed_in_user(params)
      employee_number = params[:created_by_id]
      if User.find_by_employee_number(employee_number).nil?
        flash[:error] = "The employee number you entered does not exsist."
        redirect_to ticket_path
      else
        params[:created_by_id] = User.find_by_employee_number(employee_number).id
        @task = Task.new(params)
        Task.add_file_attachment(@task, attachment_params[:attachments]) unless attachment_params.empty?
        if @task.save!
          Task.send_ticket_email(@task, params[:created_by_id])
          flash[:notice] = "Successfully created ticket."
          redirect_to root_path
        else
          flash[:error] = "Ticket creation failed. "
          redirect_to ticket_path
        end
      end
    end
end