class AddAttachmentsToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :attachments, :json
  end
end
