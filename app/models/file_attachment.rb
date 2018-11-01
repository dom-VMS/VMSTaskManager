class FileAttachment < ApplicationRecord
  mount_uploader :file, AttachmentUploader

  belongs_to :task, optional: true
  belongs_to :comment, optional: true

  # Validations
  #validates_presence_of :file
  #validates_integrity_of :file
end
