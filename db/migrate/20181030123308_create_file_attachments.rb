class CreateFileAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :file_attachments do |t|
      t.references :task, foreign_key: true
      t.references :comment, foreign_key: true
      t.string :file

      t.timestamps
    end
  end
end
