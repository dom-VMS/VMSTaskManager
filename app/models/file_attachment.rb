class FileAttachment < ApplicationRecord
  belongs_to :task, optional: true
  belongs_to :comment, optional: true

  mount_uploader :file, AttachmentUploader
end
