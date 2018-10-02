class Task < ApplicationRecord
    has_many :comments, dependent: :destroy
    has_one :task_type
    validates :title, presence: true, 
                    length: { minimum: 5 }
   validates_presence_of :task_types_id
end
