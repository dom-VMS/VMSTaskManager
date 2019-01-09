class AttachmentsController < ApplicationController
    def create
    end

    def destroy
        @task = Task.find_by_id(attachment_params[:task_id])
        remove_attachment_at_index(attachment_params[:id].to_i)
        @task.save ? (flash[:notice] = "File removed") : (flash[:danger] = "Something went wrong. File could not be removed.")
        
        respond_to do |format|
        format.html { redirect_to @task }
        end
    end

    private
      def attachment_params
        params.permit(:task_id, :id)
      end
    protected
     #
      def remove_attachment_at_index(index)
        attachments = @task.attachments # copy the array
        puts "This is attachments:\n\n #{attachments} \n\n"
        puts "\n\n THIS IS INDEX: #{index} \n\n"
        attachments.delete_at(index)
        puts "This is attachments after deletion:\n\n #{attachments} \n\n"
        @task.attachments = attachments
      end
end
