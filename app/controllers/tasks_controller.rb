require 'date'

class TasksController < ApplicationController
    http_basic_authenticate_with name: "admin", password: "Vms.1946!", only: :destroy

    def index
        @tasks = Task.all
    end
    
    def show
        @task = Task.find(params[:id])
        @assignee = TaskAssignment.get_assignee(@task)
        @hours_spent = LoggedLabor.hours_spent_on_task(@task)
        @date = (@task.created_at).strftime("%m/%d/%Y") 
    end
    
    def new
        @task = Task.new
        @task_assignment = TaskAssignment.new
    end

    def edit
        @task = Task.find(params[:id])
        @assignee = TaskAssignment.get_assignee_object(@task);
        @task_type = TaskType.find_by_id(@task.task_type_id)
        @assignable_users = []
        (@task_type.task_type_options).each do |task_type_options|
            @assignable_users.concat(task_type_options.users)
        end

    end

    def create
        @task = Task.new(new_task_params)

        if @task.save!
            redirect_to @task
            @task_assignment = TaskAssignment.create(task_id: @task.id, assigned_to_id: assignment_params_new[:assigned_to_id])
            @task_assignment.save!
        else
            render 'new'
        end

    end

    def update
        @task = Task.find(params[:id])
        @task_assignment = TaskAssignment.where("task_id = #{params[:id]}")

        if @task.update(edit_task_params)
            @task_assignment.exists? ? @task_assignment.update(assignment_params) : TaskAssignment.create(assignment_params)
            redirect_to @task
        else
          render 'edit'
        end
    end

    def destroy
        @task = Task.find(params[:id])
        @task.destroy
       
        redirect_to home_index_path
    end

    private
      def new_task_params
        params.require(:task).permit(:title, :description, :priority, :status, :percentComplete, :task_type_id)
      end

      def edit_task_params
        params.require(:task).permit(:title, :description, :priority, :status, :percentComplete)
      end

      def assignment_params
        params.require(:task).permit(:task_id, :assigned_to_id)
      end

      def assignment_params_new
        params.require(:task).permit(:assigned_to_id)
      end
end
