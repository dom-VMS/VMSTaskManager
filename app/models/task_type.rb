class TaskType < ApplicationRecord
    include PublicActivity::Model
    tracked

    has_many :tasks, dependent: :destroy
    has_many :task_type_options, dependent: :destroy
    has_many :task_queues, dependent: :destroy

    belongs_to :parent, class_name: "TaskType", optional: true
    has_many :children, class_name: "TaskType", :foreign_key => "parent_id"

    validates :name, presence: true

    tracked owner: Proc.new{ |controller, model| controller.current_user }

    # Returns all the task_types a user belongs to a user.
    def self.get_task_types_assigned_to_user(current_user)
        tto = current_user.task_type_options
        return nil if tto.empty?

        user_task_types = tto.pluck(:task_type_id)
        return user_task_types
    end

    # Returns all users that belongs to a given task_type.
    # This is all user assigned to the the top-most parent + any other user 
    # That may be directly assigned to the given task_type
    def self.get_users(task_type)
        if task_type.parent.present?
            parent_project = TaskType.get_top_most_parent(task_type)
            task_type_options = parent_project.task_type_options
            task_type_options += task_type.task_type_options
        else 
            task_type_options = task_type.task_type_options
        end        
        tto_id = task_type_options.map(&:id)
        ug = UserGroup.where(task_type_option_id: [tto_id])
        user_ids = ug.map(&:user_id)
        return User.where(id: [user_ids])
    end

    # Returns all admin users that belong to a given task_type.
    # If no admin is directly defined, check the top-most parent project.
    def self.get_admins(task_type)
        if task_type.task_type_options.where(isAdmin: true).any?
            tto = TaskTypeOption.find_by(task_type_id: task_type.id, isAdmin: true)
            return tto.users
        elsif task_type.parent.present?
            parent = TaskType.get_top_most_parent(task_type)
            tto = TaskTypeOption.find_by(task_type_id: parent.id, isAdmin: true)
            tto.users.nil? ? (return nil) : (return tto.users)
        end
    end

    # Returns an array of all the sub-projects related to a task_type.
    # Not just first-level children. This will return ALL children to a task_type.
    def self.get_all_sub_projects(task_type)
        sub_projects = task_type.children
        sub_projects.each do |sub_project|
            if sub_project.children.any?
                sub_projects += TaskType.get_all_sub_projects(sub_project)
            end
        end
        sub_projects
    end

    # Given a task_type, this method will iterate task_type.parent until it has reached 
    # the highest level project. (parent)
    def self.get_top_most_parent(task_type)
        parent_project = task_type.parent
        while parent_project.parent != nil
            parent_project = parent_project.parent
        end
        parent_project
    end

    # Returns an array of a given task_type + all children under it.
    # Used in task#edit.
    def self.get_list_of_assignable_projects(task_type)
        projects = [task_type]
        projects.each do |sub_project|
            if sub_project.children.any?
                projects += TaskType.get_all_sub_projects(sub_project)
            end
        end
        projects
    end

    # Search function for TaskTypes.
    def self.search(search)
        unless search.empty?
            TaskType.where('name LIKE ?', "%#{sanitize_sql_like(search)}%")
        else
            TaskType.all
        end
    end

end
