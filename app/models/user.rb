# User Model
# Attributes: id, employee_number, f_name, l_name, email, hourly_rate, password_digest.
# Primary Key: id
# Foreign Key(s): None

class User < ApplicationRecord
    has_many :logged_labors

    has_many :user_groups, dependent: :destroy
    has_many :task_type_options, through: :user_groups

    has_many :task_assignments, dependent: :destroy
    has_many :tasks, through: :task_assignments

    validates :f_name,  presence: true, length: { maximum: 25 }
    validates :l_name,  presence: true, length: { maximum: 25 }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                format: {with: VALID_EMAIL_REGEX}
    validates :password_digest, presence: true, length: { minimum: 6 }

   validates_presence_of :employee_number

   has_secure_password

    def full_name
        "#{f_name} #{l_name}"
    end
end
