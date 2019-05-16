class Comment < ApplicationRecord
  ## PublicActivity Set-up
  include PublicActivity::Model
  tracked

  ## Carrierwave Set-up
  mount_uploaders :attachments, AttachmentUploader

  ## Active Record Associations
  belongs_to :task
  belongs_to :commenter, class_name: "User", optional: true
  has_many :file_attachments, dependent: :destroy

  ## Active Record Validations
  validates_presence_of :body, :message => "of the comment cannot be empty."

  ## PublicActivity
  tracked owner: Proc.new{ |controller, model| controller.current_user }
  tracked  recipient: ->(controller, model) { model && model.task }
end
