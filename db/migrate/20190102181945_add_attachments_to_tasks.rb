class AddAttachmentsToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :attachments, :json
  end
end
