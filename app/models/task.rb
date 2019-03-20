require 'my_utilities'

class Task < ApplicationRecord
    include PublicActivity::Model
    #include Filterable 
    tracked

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
    has_many :users, through: :task_assignments

    accepts_nested_attributes_for :file_attachments, :task_assignments
    
    #validates :title, presence: true
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

    # Retrieve all open tasks that the current user is permitted to work on.
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

    # Retrieve all open tasks that a User is permitted to verify.
    def self.get_all_tasks_user_can_verify(user)
        tto = user.task_type_options
        if tto.empty?
            return nil
        else
            ttoHash = tto.pluck(:task_type_id, :can_verify).to_h
            task_types = ttoHash.select { |key, value| value == true }
            task_types = task_types.keys
            # task_types = tto.pluck(:task_type_id) <-- Consider reimplementing this and just making the buttons disabled.
            return (Task.where(isVerified: [nil, false]).
                        where(status: 3).
                        where(task_type_id: [task_types]).
                        order("updated_at DESC"))
        end
    end

    # Retrieve all open tasks that the current user is permitted to approve.
    def self.get_all_tickets_user_can_approve(user)
        tto = user.task_type_options
        if tto.empty?
            return nil
        else
            ttoHash = tto.pluck(:task_type_id, :can_approve).to_h
            task_types = ttoHash.select { |key, value| value == true }
            task_types = task_types.keys
            # task_types = tto.pluck(:task_type_id) <-- Consider reimplementing this and just making the buttons disabled.
            return (Task.where(isApproved: [nil]).
                        where(task_type_id: [task_types]).
                        order("updated_at DESC"))
        end
    end

=begin
    SELECT t.*, ta.assigned_to_id, tq.position
    FROM tasks t
    INNER JOIN task_assignments ta
        ON t.id = ta.task_id
    LEFT JOIN task_queues tq
        ON t.id = tq.task_id
        AND ta.assigned_to_id = tq.user_id
    WHERE t.task_type_id IN (2, 4)
        AND (t.isVerified = 0 OR t.isVerified IS NULL)
        AND t.percentComplete != 100
        AND (NOT(t.isApproved = 0 OR t.isApproved is NULL))
        AND (ta.assigned_to_id = #{user.id} OR ta.assigned_to_id IS NULL)
    ORDER BY ISNULL(tq.position), tq.position ASC;
=end
    # Returns all tasks assigned to a current user.
    def self.get_all_tasks_assigned_to_user(user)
        tto = user.task_type_options #Grab the current user's role(s).
        return nil if tto.empty?

        user_task_types = tto.pluck(:task_type_id) #Returns projects the user belongs to.
        task_assignment_joins_task_queue= TaskAssignment.joins("LEFT JOIN task_queues ON task_queues.task_id = task_assignments.task_id AND task_queues.user_id = #{user.id}")
        task_joins_task_assignments = Task.joins(:task_assignments).select("tasks.*, task_assignments.assigned_to_id, task_queues.position").
                                                                    where(task_type_id: [user_task_types]).
                                                                    where(isVerified: [nil, false]).
                                                                    where("task_assignments.assigned_to_id = #{user.id}").
                                                                    where.not(percentComplete: 100).
                                                                    where.not(isApproved: [nil, false]).
                                                                    order(Arel.sql("ISNULL(task_queues.position), task_queues.position ASC;"))
        return task_joins_task_assignments.merge(task_assignment_joins_task_queue)
    end

    # Returns all assigned tasks given to a user based on a particular task_type.
    def self.get_tasks_assigned_to_user_for_task_type(task_type, user)
        tto = user.task_type_options
        return nil if tto.empty?

        user_task_types = tto.pluck(:task_type_id)
        if user_task_types.include? task_type.id
            task_assigment_relation = TaskAssignment.where(assigned_to_id: user.id)
            task_type_relation = Task.joins(:task_assignments).
                                      where(task_type_id: task_type.id).
                                      where(isVerified: [nil, false]).
                                      where.not(percentComplete: 100).
                                      where.not(isApproved: [nil, false]).
                                      order("created_at DESC")

            return task_type_relation.merge(task_assigment_relation)
        else 
            return nil
        end
    end

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
