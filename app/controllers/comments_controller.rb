class CommentsController < ApplicationController
    def create
        @task = Task.find(params[:task_id])
        @comment = @task.comments.create(comment_params)
        add_file_attachment(attachment_params[:attachments]) unless attachment_params.empty?
        @comment.save! ? (flash[:notice] = "Successfully created comment.") : (flash[:error] = "Failed to create comment")
        respond_to do |format|
          format.html { redirect_to @task }
        end
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
          params.require(:comment).permit({attachments: []})
        end
      protected

      # Adds the uploaded file(s) to the array for attachments
      def add_file_attachment(new_attachments)
        attachments = @comment.attachments
        attachments += new_attachments
        @comment.attachments = attachments
      end
end
