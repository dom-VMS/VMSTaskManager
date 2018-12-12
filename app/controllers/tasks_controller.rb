require 'date'

class TasksController < ApplicationController
    def index
        @task = Task.get_all_tasks_user_can_see(current_user)
    end
    
    def show
        @task = find_task
        @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task.task_type_id) unless !current_user.present?
        @activities = ActivitiesHelper.get_activities(@task)
        @assignee = TaskAssignment.get_assignee_object(@task)
    end
    
    def new
        @task = Task.new
        @task_assignment = TaskAssignment.new
        @task_type = find_task_type        
        @task.file_attachments.build
        @assignable_users = Task.get_assignable_users(@task_type.task_type_options)
    end

    def ticket
        @task = Task.new
        @task_type = find_task_type
        @task.file_attachments.build
    end

    def create_ticket
        @task = Task.new(new_task_params)
        if @task.save!
            @task_assignment.save!
            add_file_attachment
            flash[:notice] = "Your ticket has been created!"
            logged_in? ? (redirect_to 'home/index') : (redirect_to 'home/welcome')
        else
            flash[:danger] = "Ticket entry failed!"
            render 'new'
        end
    end

    def review
        @task = Task.where(isApproved: nil).order("created_at DESC")
    end

    def verify
        @task = Task.get_all_tasks_user_can_verify(current_user)
    end

    def update_ticket
        task = Task.find_by_id(review_ticket_params[:id])
        if task.update(review_ticket_params)
            if (review_ticket_params[:isApproved] == "true")
                flash[:notice] = "Ticket Approved! You can now add more information to the task and/or assign someone to this."
                redirect_to edit_task_path(task)
            elsif (review_ticket_params[:isApproved] == "false")
                flash[:notice] = "Ticket Rejected."
                redirect_to review_path
            elsif (review_ticket_params[:isVerified] == "true")
                flash[:notice] = "Task Completion Approved."
                redirect_to task_path(task)
            elsif (review_ticket_params[:isVerified] == "false")
                flash[:notice] = "Task Completion Rejected."
                redirect_to task_path(task)
            else
                flash[:notice] = "Something went wrong"
                render 'home/index'
            end
            #redirect_to task
        else
          render 'edit'
        end
    end

    def edit
        @task = find_task
        @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task.task_type_id) unless !current_user.present?
        @assignee = TaskAssignment.get_assignee_object(@task);
        @task_type = TaskType.find_by_id(@task.task_type_id)
        @assignable_users = Task.get_assignable_users(@task_type.task_type_options)
        puts @assignable_users.to_json 
    end

    def create
        params = new_task_params 
        unless logged_in?
            if User.exists?(new_task_params[:created_by_id])
                params[:created_by_id] = User.find_by_employee_number(new_task_params[:created_by_id]).id                
            else 
                flash[:error] = "The employee number you have entered does not exsist."
                render 'ticket'
            end
        end
        @task = Task.new(params)
        #@task = Task.new(new_task_params)
        if @task.save!
            @task_assignment = TaskAssignment.create(task_id: @task.id, assigned_to_id: assignment_params_new[:assigned_to_id])
            @task_assignment.save!
            add_file_attachment
            flash[:notice] = "Successfully created task."
            redirect_to @task
        else
            flash[:error] = "Task creation failed"
            render 'new'
        end
    end

    def update
        @task = find_task
        @task_type_id = @task.task_type_id
        @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task.task_type_id) unless !current_user.present?
        @task_type = TaskType.find_by_id(@task.task_type_id)
        @assignable_users = Task.get_assignable_users(@task_type.task_type_options)
        @task_assignment = TaskAssignment.where("task_id = #{params[:id]}")
        puts "LOOK HERE #{@task_assignment.to_json}"
        add_file_attachment

        if @task.update(edit_task_params)
            @task_assignment.exists? ? @task_assignment.update(assignment_params) : TaskAssignment.create(assignment_params)
            flash[:notice] = "Task updated!"
            redirect_to @task
        else
          render 'edit'
        end
    end

    def destroy
        @task = find_task
        @task.destroy
        redirect_to task_type_path(@task.task_type_id)
    end

    private
      def new_task_params
        params.require(:task).permit(:title, :description, :priority, :status, :percentComplete,  :isApproved, :task_type_id, :created_by_id)
      end

      def edit_task_params
        params.require(:task).permit(:title, :description, :priority, :status, :percentComplete,  :isApproved)
      end

      def assignment_params
        params.require(:task).permit(:task_id, :assigned_to_id, :assigned_by_id)
      end

      def assignment_params_new
        params.require(:task).permit(:assigned_to_id, :assigned_by_id)
      end

      def attachment_params
        params.require(:task).permit(file_attachments_attributes: [:id, :file])
      end

      def review_ticket_params
        params.permit(:id, :isApproved, :isVerified, :status, :percentComplete)
      end
    
    protected
      # Finds task by id
      def find_task
        Task.find(params[:id])
      end

      # Finds task_type by task_type_id (used when creating a new task)
      def find_task_type
        TaskType.find_by_id(params[:task_type_id])
      end

      # Creates a new file_attachment entry if an attachment has been uploaded.
      def add_file_attachment
        if !(attachment_params[:file_attachments_attributes]).nil?
            @task.file_attachments.create(:task_id => attachment_params[:task], :file => attachment_params[:file_attachments_attributes][:file])
        end
      end
end
