class User < ApplicationRecord

    attr_accessor :remember_token

    has_many :logged_labors
    has_many :created_tasks, class_name: "Task", :foreign_key => "created_by_id"
    has_many :completed_tasks, class_name: "Task", :foreign_key => "completed_by_id"
    has_many :verified_tasks, class_name: "Task", :foreign_key => "verified_by_id"
    has_many :comments, class_name: "Comment", :foreign_key => "commenter_id"


    #has_many :through Association (users x user_groups x task_type_options)
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

    # Returns full name of a user.
    def full_name
        name = "#{f_name} #{l_name}"
        if name.nil?
           return ""
        end
        return name
    end

    
    # Returns the hash digest of the given string.
    def self.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # Returns a random token
    def self.new_token
        SecureRandom.urlsafe_base64
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Forgets a user.
    def forget
        update_attribute(:remember_digest, nil)
    end

    # Returns true if the given token matches the digest.
    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end

    # Returns User(s) based on input of search
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
