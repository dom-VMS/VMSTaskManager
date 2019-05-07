class AttachmentsController < ApplicationController
    def create
    end

    def destroy
        @task = Task.find_by_id(attachment_params[:task_id])
        Task.remove_attachment_at_index(@task, attachment_params[:id].to_i)
        @task.save ? (flash[:notice] = "File removed.") : (flash[:danger] = "Something went wrong. File could not be removed.")
        respond_to do |format|
            format.html { redirect_to task_path(@task, :param => 'edit') }
        end
    end

    private
      def attachment_params
        params.permit(:task_id, :id)
      end
end
