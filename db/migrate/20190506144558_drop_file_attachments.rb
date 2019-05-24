class DropFileAttachments < ActiveRecord::Migration[5.2]
  def change
    drop_table :file_attachments
  end
end
