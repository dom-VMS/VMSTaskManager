require 'date'

class TasksController < ApplicationController
    def index
        @task = Task.where(isVerified: nil).
                     where.not(isApproved: [nil, false]).
                     order("created_at DESC")
        user_group = current_user.user_groups
        @task_types = []
        user_group.each do |ug| 
            @task_types.push(TaskType.find_by_id(ug.task_type_option.task_type_id))
        end
    end
    
    def show
        @task = Task.find(params[:id])
        @assignee = TaskAssignment.get_assignee(@task)
        @hours_spent = LoggedLabor.hours_spent_on_task(@task)
        @date = (@task.created_at).strftime("%m/%d/%Y") 
        @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task.task_type_id)
        @logged_labors = LoggedLabor.where(:task_id => @task.id)
        @hours_spent = LoggedLabor.hours_spent_on_task(@task)
        @activities = TasksHelper.get_activities(@task)
    end
    
    def new
        @task = Task.new
        @task_assignment = TaskAssignment.new
        @task_type = TaskType.find_by_id(params[:task_type_id])        
        @task.file_attachments.build
        @assignable_users = Task.get_assignable_users(@task_type.task_type_options)
    end

    def ticket
        @task = Task.new
        @task_type = TaskType.find_by_id(params[:task_type_id])        
        @task.file_attachments.build
    end

    def create_ticket
        @task = Task.new(new_task_params)
        if @task.save!
            @task_assignment = TaskAssignment.create(task_id: @task.id, assigned_to_id: (User.where("employee_number = #{assignment_params_new[:assigned_to_id]}").id))
            @task_assignment.save!
            if !(attachment_params[:file_attachments_attributes]).nil?
                @task.file_attachments.create(:task_id => attachment_params[:task], :file => attachment_params[:file_attachments_attributes][:file])
            end
            flash[:notice] = "Your ticket has been created!"
            logged_in? ? (redirect_to 'home/index') : (redirect_to 'home/welcome')
        else
            render 'new'
        end
    end

    def review
        @task = Task.where(isApproved: nil).order("created_at DESC")
    end

    def update_ticket
        task = Task.find_by_id(review_ticket_params[:id])
        if task.update(review_ticket_params)
            if (review_ticket_params[:isApproved] == "true")
                flash[:notice] = "Ticket Approved!"
            elsif (review_ticket_params[:isApproved] == "false")
                flash[:notice] = "Ticket Rejected!"
            end
            
            redirect_to task
        else
          render 'edit'
        end
    end

    def edit
        @task = Task.find(params[:id])
        @assignee = TaskAssignment.get_assignee_object(@task);
        @task_type = TaskType.find_by_id(@task.task_type_id)
        @assignable_users = Task.get_assignable_users(@task_type.task_type_options)
    end

    def create
        @task = Task.new(new_task_params)
        if @task.save!
            @task_assignment = TaskAssignment.create(task_id: @task.id, assigned_to_id: assignment_params_new[:assigned_to_id])
            @task_assignment.save!
            if !(attachment_params[:file_attachments_attributes]).nil?
                @task.file_attachments.create(:task_id => attachment_params[:task], :file => attachment_params[:file_attachments_attributes][:file])
            end
            flash[:notice] = "Successfully created task."
            redirect_to @task
        else
            render 'new'
        end
    end

    def update
        @task = Task.find(params[:id])
        @task_assignment = TaskAssignment.where("task_id = #{params[:id]}")

        if !(attachment_params[:file_attachments_attributes]).nil?
            @task.file_attachments.create(:task_id => attachment_params[:task], :file => attachment_params[:file_attachments_attributes][:file])
        end

        if @task.update(edit_task_params)
            @task_assignment.exists? ? @task_assignment.update(assignment_params) : TaskAssignment.create(assignment_params)
            flash[:notice] = "Task updated!"
            redirect_to @task
        else
          render 'edit'
        end
    end

    def destroy
        @task = Task.find(params[:id])
        @task.destroy
       
        redirect_to task_type_path(@task.task_type_id)
    end

    private
      def new_task_params
        params.require(:task).permit(:title, :description, :priority, :status, :percentComplete,  :isApproved, :task_type_id)
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
        params.permit(:id, :isApproved)
      end
end
