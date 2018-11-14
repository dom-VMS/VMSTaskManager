class FileAttachment < ApplicationRecord
  mount_uploader :file, AttachmentUploader

  include PublicActivity::Model
  tracked

  belongs_to :task, optional: true
  belongs_to :comment, optional: true

  tracked owner: Proc.new{ |controller, model| controller.current_user }
  tracked  recipient: ->(controller, model) { model && model.task }
end
