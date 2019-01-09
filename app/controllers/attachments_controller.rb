class AttachmentsController < ApplicationController
    def create
    end

    def destroy
        @task = Task.find_by_id(attachment_params[:task_id])
        remove_attachment_at_index(attachment_params[:id].to_i)
        @task.save ? (flash[:notice] = "Successfully removed file.") : (flash[:danger] = "Something went wrong. File could not be removed.")
        respond_to do |format|
            format.html { redirect_to @task }
        end
    end

    private
      def attachment_params
        params.permit(:task_id, :id)
      end

    protected
     # Locates an attachment at a gievn index and removes it from the database.
      def remove_attachment_at_index(index)
        attachments = @task.attachments # copy the array
        attachments.delete_at(index)
        @task.attachments = attachments
      end
end
