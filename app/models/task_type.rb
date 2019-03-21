class TaskType < ApplicationRecord
    include PublicActivity::Model
    tracked

    has_many :tasks, dependent: :destroy
    has_many :task_type_options, dependent: :destroy
    has_many :task_queues, dependent: :destroy

    validates :name, presence: true

    tracked owner: Proc.new{ |controller, model| controller.current_user }

    # Returns all the task_types a user belongs to a user.
    def self.get_task_types_assigned_to_user(current_user)
        tto = current_user.task_type_options
        return nil if tto.empty?

        user_task_types = tto.pluck(:task_type_id)
        return user_task_types
    end

    def self.get_users(task_type)
        task_type_options = task_type.task_type_options
        tto_id = task_type_options.map(&:id)
        ug = UserGroup.where(task_type_option_id: [tto_id])
        user_ids = ug.map(&:user_id)
        return User.where(id: [user_ids])
    end

    def self.get_admins(task_type)
        task_type_options = task_type.task_type_options
        isAdminIds = task_type_options.select(:id).where(isAdmin: true)
        unless isAdminIds.nil?
            admins = UserGroup.select(:user_id).where(task_type_option_id: isAdminIds)
            user_ids = admins.pluck(:user_id)
            users = User.where(id: user_ids)
        end
    end

    def self.search(search)
        unless search.empty?
            TaskType.where('name LIKE ?', "%#{sanitize_sql_like(search)}%")
        else
            TaskType.all
        end
    end
end
