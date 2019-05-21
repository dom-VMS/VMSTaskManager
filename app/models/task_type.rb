class TaskType < ApplicationRecord
    ## Public Activity Set-up
    include PublicActivity::Model
    tracked

    ## Active Record Callback
    after_create :create_roles

    ## Active Record Associations
    has_many :tasks, dependent: :destroy
    has_many :task_type_options, dependent: :destroy
    has_many :task_queues, dependent: :destroy
    belongs_to :parent, class_name: "TaskType", optional: true
    has_many :children, class_name: "TaskType", :foreign_key => "parent_id", dependent: :destroy

    ## Scopes
    scope :top_parent, -> { where(parent_id: nil) }
    scope :siblings, -> { where(parent_id: self.parent_id)}

    ## Validations
    validates :name, presence: true

    ## PublicActivity
#    tracked owner: Proc.new{ |controller, model| controller.current_user }

    # When a project is created, generate Manager and Member roles for that project
    def create_roles
        # Build & save the new roles
        manager_role = self.task_type_options.build(name: 'Manager', isAdmin: true, can_view: true, can_create: true, can_update: true, can_delete: true, can_approve: true, can_verify: true, can_comment: true, can_log_labor: true, can_view_cost: true)
        member_role = self.task_type_options.build(name: 'Member', isAdmin: false, can_view: true, can_create: false, can_update: false, can_delete: false, can_approve: false, can_verify: false, can_comment: true, can_log_labor: true, can_view_cost: false)
        manager_role.save!
        member_role.save!

        # Assign the user who created the project as a Manager. User.id is grabbed from the monitored Activity.
        user_id = created_by_id
        unless user_id.nil?
            assign_manager = manager_role.user_groups.build(user_id: user_id)
            assign_manager.save!
        end
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
        sub_projects = task_type.children.includes(:children)
        sub_projects.each do |sub_project|
            if sub_project.children.any?
                sub_projects += TaskType.get_all_sub_projects(sub_project)
            end
        end
        sub_projects
    end

    # Returns an array of a given task_type + all parent(s) & children in the realted tree.
    # Used in task#edit.
    def self.get_assignable_projects(task_type)
        projects = []
        parent_project = TaskType.includes(:children).get_top_most_parent(task_type) 
        projects.append(parent_project)
        projects += TaskType.includes(:children).get_all_sub_projects(parent_project)
        projects.uniq
    end

    # Given a task_type, this method will iterate task_type.parent until it has reached 
    # the highest level project. (parent)
    def self.get_top_most_parent(task_type)
        parent_project = task_type.parent.present? ? task_type.parent : task_type 
        while parent_project.parent.present?
            parent_project = parent_project.parent
        end
        parent_project
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

    # Search function for TaskTypes.
    def self.search(search)
        unless search.empty?
            TaskType.where('name LIKE ?', "%#{sanitize_sql_like(search)}%")
        end
    end

    # Retrieves all projects in hierarchical order
    def self.get_all_projects_in_order(parent_projects)
        parent_projects = parent_projects.order('name ASC')
        ordered_task_types = []
        parent_projects.each do |parent|
            ordered_task_types.append(parent)
            ordered_task_types += (TaskType.get_all_projects_in_order(parent.children)) if parent.children.present?
        end
        ordered_task_types
    end

end
