class User < ApplicationRecord
    has_many :logged_labors
    has_many :user_groups, dependent: :destroy
    has_many :task_type_options, through: :user_groups

    #has_many :through Association (users x task_queues x tasks)
    has_many :task_queues, dependent: :destroy
    has_many :tasks, through: :task_queues

    #has_many :through Association (users x task_assignments x tasks)
    has_many :task_assignments, dependent: :destroy, foreign_key: 'assigned_to_id'
    has_many :tasks, through: :task_assignments

    has_secure_password

    validates :f_name,  presence: true, length: { maximum: 25 }
    validates :l_name,  presence: true, length: { maximum: 25 }

    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                format: {with: VALID_EMAIL_REGEX}

    validates_presence_of :employee_number
    validates :password, presence: true, length: { :within => 3..40 }, on: :create 
    validates :password, allow_blank: true, length: { :within => 3..40 }, on: :update 


    def full_name
        name = "#{f_name} #{l_name}"
        if name.nil?
           return ""
        end
        return name
    end

    def self.search(search)
        unless search.empty?
            if regex_is_number? search
                User.where(employee_number: search)
            else
                User.where("CONCAT_WS( ' ', f_name, l_name) LIKE ?", "%#{sanitize_sql_like(search)}%")
            end
        else
            User.all
        end
    end
end
