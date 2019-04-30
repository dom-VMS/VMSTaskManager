class Comment < ApplicationRecord
  include PublicActivity::Model
  tracked
  mount_uploaders :attachments, AttachmentUploader

  belongs_to :task
  has_many :file_attachments, dependent: :destroy

  validates_presence_of :body, :message => "of the comment cannot be empty."

  tracked owner: Proc.new{ |controller, model| controller.current_user }
  tracked  recipient: ->(controller, model) { model && model.task }
end
