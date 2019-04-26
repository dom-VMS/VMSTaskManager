class TasksController < ApplicationController
  skip_before_action :require_login, only: [:ticket, :create]
  before_action :all_tasks, only: [:index, :update]
  before_action :find_task, only: [:show, :edit, :update, :destroy]


  def index
    task_type_ids = TaskType.get_task_types_assigned_to_user(current_user)
    @task_types = TaskType.where(id: [task_type_ids])
  end

  def show
    @task_type = TaskType.find_by_id(@task.task_type_id)
    get_current_user_task_type_options
    @activities = ActivitiesHelper.get_activities(@task)
    @assignees = @task.users
    get_assignable_users        
  end
  
  def new
    @task_type = find_task_type  
    current_task_type_option = @task_type.nil? ? current_user.task_type_options : TaskTypeOption.get_task_type_specific_options(current_user, @task_type)
    if current_task_type_option.nil?
        flash[:error] = "Sorry, but you do not have permission to create #{@task_type.name} task."
        redirect_to  new_task_type_task_path(@task_type)
    else
        @task = Task.new
        @task_assignment = @task.task_assignments.build
        @task.file_attachments.build
        get_assignable_users        
    end 
  end

  def edit
    @task_type = TaskType.find_by_id(@task.task_type_id)
    validate_current_user
    get_current_user_task_type_options  
    if @task_type_option.nil? || @task_type_option.can_update? == false
      flash[:error] = "Sorry, but you do not have permission to edit tasks."
      redirect_to task_path(@task)
    end
    @assignees = @task.users
    get_assignable_users
    @sub_projects = TaskType.get_list_of_assignable_projects(@task_type)
  end

  def create
    params = task_params 
    if logged_in?
      @task = Task.new(params)
      add_file_attachment(attachment_params[:attachments]) unless attachment_params.empty?
      if @task.save!
        if @task.isApproved.nil?
          send_ticket_email(@task, current_user.id)
        end
        flash[:notice] = "Successfully created task."
        redirect_to @task
      else
        flash[:error] = "Task creation failed. "
        render 'new'
      end  
    else 
      task_creation_for_not_signed_in_user(params)
    end
  end

  def update
    add_file_attachment(attachment_params[:attachments]) unless attachment_params.empty?
    if @task.update(task_params)
        flash[:notice] = "Task updated!"
        respond_to do |format|
            format.html { redirect_to @task }
        end
    else
        flash[:notice] = "Something went wrong." 
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

  def review
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
    @task = Task.where(isVerified: [nil, false]).where(status: 3).where(task_type_id: [@task_types]).order("updated_at DESC")
  end

  def update_ticket
    task = Task.find_by_id(review_ticket_params[:id])
    if task.update(review_ticket_params)
        if (review_ticket_params[:isApproved] == "true")
            flash[:notice] = "Ticket Approved! You can now add more information to the task and/or assign someone to this."
            TaskMailer.with(task: task).ticket_approved.deliver_later
            redirect_to edit_task_path(task) # Send user to task#edit.
        elsif (review_ticket_params[:isApproved] == "false")
            insert_decline_feedback(task)
            flash[:notice] = "Ticket Rejected."
            TaskMailer.with(task: task, rejected_by: decline_feedback_params[:commenter], feedback: decline_feedback_params[:body]).ticket_rejected.deliver_later
            redirect_back fallback_location: review_path
        elsif (review_ticket_params[:isVerified] == "true")
            flash[:notice] = "Task Completion Approved."
            redirect_back fallback_location:verify_path
            remove_comepleted_task_from_queue(task)
        elsif (review_ticket_params[:isVerified] == "false")
            insert_decline_feedback(task)
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
      params.require(:task).permit(:title, :description, :due_date, :priority, :status, :percentComplete,  :isApproved, :task_type_id, :created_by_id, task_assignments_attributes:[:id, :assigned_to_id, :assigned_by_id])
    end

    def assignment_params
      params.fetch(:task_assignments, {}).permit(:id, :assigned_to_id, :assigned_by_id)
    end

    def assignment_params_new
      params.require(:task).permit(:assigned_to_id, :assigned_by_id)
    end

    def attachment_params
      params.require(:task).permit({attachments: []})
    end

    def review_ticket_params
      params.require(:task).permit(:id, :isApproved, :isVerified, :status)
    end

    def decline_feedback_params
      params.require(:task).permit(:commenter, :body)
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
      TaskType.find_by_id(params[:task_type_id])
    end

    # Adds the uploaded file(s) to the array for attachments
    def add_file_attachment(new_attachments)
      attachments = @task.attachments
      attachments += new_attachments
      @task.attachments = attachments
    end

    # Removes a file, from the array of files, at the index the user clicks.
    def remove_attachment_at_index(index)
      attachments = @task.attachments # copy the array
      @task.attachments = attachments.delete_at(index) # delete the target attachment
    end

    # Gets the current user's Task_Type_Options
    def get_current_user_task_type_options
      @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task.task_type) unless !current_user.present?
    end

    # Retrieves all users that may be assigned to a task.
    def get_assignable_users
      @assignable_users = TaskType.get_users(@task_type) 
    end

    # Allows an admin to place a comment in the task that is being declined to describe why it is being rejected.
    def insert_decline_feedback(task)
      comment = task.comments.create(commenter: decline_feedback_params[:commenter], body: decline_feedback_params[:body], attachments: attachment_params[:attachments])
      comment.save!
    end

    # Looks at current user's TaskTypeOptions. Determines if they are permitted to view/edit data.
    def validate_current_user 
      @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type)
      if @task_type_option.nil?
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
        add_file_attachment(attachment_params[:attachments]) unless attachment_params.empty?
        if @task.save!
          send_ticket_email(@task, params[:created_by_id])
          flash[:notice] = "Successfully created ticket."
          redirect_to root_path
        else
          flash[:error] = "Ticket creation failed. "
          redirect_to ticket_path
        end
      end
    end

    # When a task is verified as complete, this funciton is called to remove the given task from any queue with it present.
    def remove_comepleted_task_from_queue(task)
      queue_items = TaskQueue.where(task_id: task.id)
      unless queue_items.nil?
        queue_items.each do |queue_item|
          queue_item.destroy
        end
      end
    end

    # Sends email to admin and users related to the ticket being filed.
    def send_ticket_email(task, user)
      #Send Email to Project Manager(s)
      TaskMailer.with(task: @task).new_ticket_created_admins.deliver_later
      #Send Email to the user
      TaskMailer.with(task: @task, user_id: user).new_ticket_created_user.deliver_later
    end
end