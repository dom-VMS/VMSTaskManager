class CommentsController < ApplicationController
    def create
        @task = Task.find(params[:task_id])
        @comment = @task.comments.create(comment_params)
        if !(attachment_params[:file_attachments_attributes]).nil?
          @comment.file_attachments.create(:task_id => attachment_params[:task], :file => attachment_params[:file_attachments_attributes][:file])
        end

        redirect_to task_path(@task)
    end

    def destroy
      @task = Task.find(params[:task_id])
      @comment = @task.comments.find(params[:id])
      @comment.destroy
      redirect_to task_path(@task)
    end
     
      private
        def comment_params
          params.require(:comment).permit(:commenter, :body)
        end

        def attachment_params
          params.require(:comment).permit(file_attachments_attributes: [:id, :file])
        end
end
