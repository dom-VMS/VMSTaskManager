class FileAttachmentsController < ApplicationController
    def create
    end

    def destroy
        @file_attachment = FileAttachment.find(params[:id])
        @task = Task.find_by_id(@file_attachment.task_id)
        @file_attachment.destroy
    
        respond_to do |format|
            format.html { redirect_to @task}
        end
       
    end
end
