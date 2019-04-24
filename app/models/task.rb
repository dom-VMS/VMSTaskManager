require 'my_utilities'
class Task < ApplicationRecord
    include PublicActivity::Model
    
    # Used for public_acitivity gem
    tracked

    # File uploader for attchaments
    mount_uploaders :attachments, AttachmentUploader

    # config/initializers/task_constants.rb
    attr_accessor :PRIORITY
    attr_accessor :STATUS

    belongs_to :task_type
    has_many :comments, dependent: :destroy
    has_many :logged_labors, dependent: :destroy
    has_many :file_attachments, dependent: :destroy  

    #has_many :through association (users x task_queues x tasks)
    has_many :task_queues, dependent: :destroy
    has_many :users, through: :task_queues

    #has_many :through association (users x task_assignments x tasks)
    has_many :task_assignments, dependent: :destroy 
    has_many :users, through: :task_assignments, source: 'assigned_to'

    accepts_nested_attributes_for :file_attachments, :task_assignments
    
    #validates :created_by_id_exists
    validates_presence_of :task_type_id
    validates :created_by_id, numericality: true

    tracked owner: Proc.new{ |controller, model| controller.current_user }

    # Retrieves all possible users that can be assigned to a task.
    def self.get_assignable_users(task_type_options)
        assignable_users = []
        task_type_options.each do |task_type_option|
            assignable_users.concat(task_type_option.users)
        end
        return assignable_users
    end

    # Retrieve all open tasks. (Tasks that have not been marked as complete)
    def self.get_open_tasks
        Task.where(isVerified: nil).
             where.not(percentComplete: 100).
             where.not(isApproved: [nil, false]).
             order("created_at DESC")
    end

    # Retrieve all open tasks that a user is permitted to work on.
    def self.get_all_tasks_user_can_see(user)
        tasks = []
        tto = user.task_type_options
        if tto.empty?
            return nil
        else
            task_types = tto.pluck(:task_type_id)
            return (Task.where(isVerified: nil).
                         where.not(percentComplete: 100).
                         where.not(isApproved: [nil, false]).
                         where(task_type_id: [task_types]).
                         order("created_at DESC"))
        end
    end

    # Retrieve all open tasks that a user is permitted to verify.
    def self.get_all_tasks_user_can_verify(user)
        task_type_ids = TaskType.get_task_types_assigned_to_user(user)
        task_types = TaskType.where(id: [task_type_ids])
        all_task_types = []
        task_types.each do |task_type|
            all_task_types += TaskType.get_list_of_assignable_projects(task_type)
        end
        return (Task.where(isVerified: [nil, false]).
                    where(status: 3).
                    where(task_type_id: [all_task_types]).
                    order("updated_at DESC"))
    end

    # Retrieve all open tasks that a user is permitted to approve.
    def self.get_all_tickets_user_can_approve(user)
        task_type_ids = TaskType.get_task_types_assigned_to_user(user)
        task_types = TaskType.where(id: [task_type_ids])
        all_task_types = []
        task_types.each do |task_type|
            all_task_types += TaskType.get_list_of_assignable_projects(task_type)
        end
        return (Task.where(isApproved: [nil]).
                    where(task_type_id: [all_task_types]).
                    order("updated_at DESC"))
    end

    # Returns all tasks assigned to a current user, combined with their task queue.
    def self.get_all_tasks_assigned_to_user(user)
        tasks = user.tasks.where(isVerified: [nil, false]).where.not(percentComplete: 100).where.not(isApproved: [nil, false])
        all_tasks = tasks.joins("LEFT OUTER JOIN task_queues ON task_queues.user_id = #{user.id} AND task_queues.task_id = tasks.id").select("tasks.*, task_queues.position").order(Arel.sql("ISNULL(task_queues.position), task_queues.position ASC;"))
        return all_tasks
    end

    # Returns all assigned tasks given to a user based on a particular task_type.
    def self.get_tasks_assigned_to_user_for_task_type(task_type, user)
        tasks = user.tasks.where(task_type_id: task_type).where(isVerified: [nil, false]).where.not(percentComplete: 100).where.not(isApproved: [nil, false]).order("created_at DESC")
    end

    # Search for a task within a given TaskType (project)
    def self.search_with_task_type(search, task_type)
        unless search.empty?
            if regex_is_number? search
                Task.where(task_type_id: task_type).where(id: search)
            else
                Task.where(task_type_id: task_type).where('title LIKE ?', "%#{sanitize_sql_like(search)}%")
            end
        else
            Task.where(task_type_id: task_type)
        end
    end

end
