class Comment < ApplicationRecord
  belongs_to :task
  has_many :file_attachments, dependent: :destroy
  #has_many :file_attachments, as: :attached_item, dependent: :destroy

end
