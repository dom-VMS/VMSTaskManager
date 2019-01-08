class TaskAssignmentsController < ApplicationController

    def new
        #@task = Task.find(params[:task_type_id])
        #task_assignment = TaskAssignment.new
    end

    def create
    end

    def destroy
        @task = Task.find(params[:task_id])
        @assigment = @task.task_assignments.find(params[:id])
        @assigment.destroy
        
        respond_to do |format|
            format.html { redirect_to @task}
         end
    end
       
end
