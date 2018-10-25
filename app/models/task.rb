class Task < ApplicationRecord
    has_many :comments, dependent: :destroy
    has_many :logged_labors, dependent: :destroy
    
    has_many :task_assignments, dependent: :destroy
    has_many :users, through: :task_assignments

    has_one :task_type
    validates :title, presence: true, 
                    length: { minimum: 5 }
    validates_presence_of :task_types_id
end
