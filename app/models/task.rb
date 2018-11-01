class Task < ApplicationRecord
    has_many :comments, dependent: :destroy
    has_many :logged_labors, dependent: :destroy
    has_many :task_assignments, dependent: :destroy
    has_many :users, through: :task_assignments

    has_many :file_attachments, dependent: :destroy   
    accepts_nested_attributes_for :file_attachments 

    has_one :task_type
    validates :title, presence: true, 
                    length: { minimum: 5 }
    validates_presence_of :task_type_id


    def self.get_assignable_users(task_type_options)
        assignable_users = []
        task_type_options.each do |task_type_option|
            assignable_users.concat(task_type_option.users)
        end
        return assignable_users
    end
end
