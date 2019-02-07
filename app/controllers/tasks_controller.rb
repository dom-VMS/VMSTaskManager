require 'date'

class TasksController < ApplicationController
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
        @assignee = TaskAssignment.get_assigned_user(@task)
        get_assignable_users        
    end
    
    def new
        @task_type = find_task_type  
        current_task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type.id)
        if current_task_type_option.nil?
            flash[:error] = "Sorry, but you do not have permission to create #{@task_type.name} task."
            redirect_to new_task_path
        else
            @task = Task.new
            @task_assignment = TaskAssignment.new
            @task.file_attachments.build
            get_assignable_users        
        end 
    end

    def edit
        @task_type = TaskType.find_by_id(@task.task_type_id)
        get_current_user_task_type_options   
        @assignee = TaskAssignment.get_assigned_user(@task);
        get_assignable_users
    end

    def create
        params = task_params 
        unless logged_in?
            if (User.find_by_employee_number(params[:created_by_id])).present?  
                params[:created_by_id] = User.find_by_employee_number(task_params[:created_by_id]).id         
            else 
                flash[:error] = "The employee number you have entered does not exsist."
                render 'ticket'
            end
        end
        @task = Task.new(params)
        add_file_attachment(attachment_params[:attachments]) unless attachment_params.empty?
        if @task.save!
            set_task_assignments unless assignment_params.empty?
            #flash[:error] = "Failed to assign user" unless @task_assignment.save!
            flash[:notice] = "Successfully created task."
            redirect_to @task
        else
            flash[:error] = "Task creation failed"
            render 'new'
        end
    end

    def update
        @task_type_id = @task.task_type_id
        get_current_user_task_type_options 
        @task_type = TaskType.find_by_id(@task.task_type_id)
        get_assignable_users
        add_file_attachment(attachment_params[:attachments]) unless attachment_params.empty?
        if @task.update_attributes(task_params)
            #set_task_assignments unless task_params[:task_assignments_attributes].empty?
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
        @task_type = TaskType.all
    end

    def review
        tto = current_user.task_type_options
        unless tto.empty?
            ttoHash = tto.pluck(:task_type_id, :can_approve).to_h
            task_types = ttoHash.select { |key, value| value == true }
            @task_types = TaskType.where(id: task_types.keys)
            @task = Task.where(isApproved: [nil]).
                        where(task_type_id: [@task_types]).
                        order("updated_at DESC")
        end
    end

    def verify
        tto = current_user.task_type_options
        unless tto.empty?
            ttoHash = tto.pluck(:task_type_id, :can_verify).to_h
            task_types = ttoHash.select { |key, value| value == true }
            @task_types = TaskType.where(id: task_types.keys)
            @task = Task.where(isVerified: [nil, false]).
                        where(status: 3).
                        where(task_type_id: [@task_types]).
                        order("updated_at DESC")
        end
    end

    def update_ticket
        task = Task.find_by_id(review_ticket_params[:id])
        if task.update(review_ticket_params)
            if (review_ticket_params[:isApproved] == "true")
                flash[:notice] = "Ticket Approved! You can now add more information to the task and/or assign someone to this."
                redirect_to edit_task_path(task)
            elsif (review_ticket_params[:isApproved] == "false")
                insert_decline_feedback(task)
                flash[:notice] = "Ticket Rejected."
                redirect_to review_path
            elsif (review_ticket_params[:isVerified] == "true")
                flash[:notice] = "Task Completion Approved."
                redirect_to verify_path
            elsif (review_ticket_params[:isVerified] == "false")
                insert_decline_feedback(task)
                flash[:notice] = "Task Completion Rejected."
                redirect_to verify_path
            else
                flash[:notice] = "Something went wrong"
                redirect_to home_path
            end
        else
          render 'edit'
        end
    end

    private

      def task_params
        params.require(:task).permit(:title, :description, :priority, :status, :percentComplete,  :isApproved, :task_type_id, :created_by_id, task_assignments_attributes:[:id, :assigned_to_id, :assigned_by_id])
      end

      def assignment_params
        params.require(:task_assignments).permit(:id, :assigned_to_id, :assigned_by_id)
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
        @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task.task_type_id) unless !current_user.present?
      end

      # Retrieves all users that may be assigned to a task.
      def get_assignable_users
        @assignable_users = Task.get_assignable_users(@task_type.task_type_options) 
      end

      # Allows an admin to place a comment in the task that is being declined to describe why it is being rejected.
      def insert_decline_feedback(task)
        comment = task.comments.create(commenter: decline_feedback_params[:commenter], body: decline_feedback_params[:body], attachments: attachment_params[:attachments])
        comment.save!
      end

      # Set task_assignment for a given task. If an assignment already exists, update. Else, create.
      def set_task_assignments
        @task_assignment = TaskAssignment.where(task_id: params[:id])
        unless @task_assignment.exists?
            TaskAssignment.create(:task_id => @task.id, :assigned_to_id => assignment_params[:assigned_to_id])
        end
      end
end
