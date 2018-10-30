class Comment < ApplicationRecord
  belongs_to :task
  has_many :file_attachments

end
