class Task < ApplicationRecord
    include PublicActivity::Model
    tracked

    has_many :comments, dependent: :destroy
    has_many :logged_labors, dependent: :destroy
    has_many :task_assignments, dependent: :destroy
    has_many :users, through: :task_assignments

    has_many :file_attachments, dependent: :destroy   
    accepts_nested_attributes_for :file_attachments 

    has_one :task_type
    validates :title, presence: true, 
                    length: { minimum: 5, message: "There must be a title."  }
    validates_presence_of :task_type_id

    tracked owner: Proc.new{ |controller, model| controller.current_user }

    # Retrieves all possible users that can be assigned to a task.
    def self.get_assignable_users(task_type_options)
        assignable_users = []
        task_type_options.each do |task_type_option|
            assignable_users.concat(task_type_option.users)
        end
        return assignable_users
    end

    # Retrieve all open tasks
    def self.get_open_tasks
        Task.where(isVerified: nil).
            where.not(percentComplete: 100).
            where.not(isApproved: [nil, false]).
            order("created_at DESC")
    end

    # Retrieve all open tasks that the current User is permitted to work on.
    def self.get_all_tasks_user_can_see(current_user)
        tasks = []
        tto = current_user.task_type_options
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

    # Returns all tasks assigned to a current user.
    def self.get_all_tasks_assigned_to_user(current_user)
        tto = current_user.task_type_options
        return nil if tto.empty?

        user_task_types = tto.pluck(:task_type_id)
        task_assigment_relation = TaskAssignment.where(assigned_to_id: [current_user.id, nil])
        task_type_relation = Task.joins(:task_assignments).where(task_type_id: [user_task_types]).
                                                           where(isVerified: nil).
                                                           where.not(percentComplete: 100).
                                                           where.not(isApproved: [nil, false]).
                                                           order("created_at DESC")

        return task_type_relation.merge(task_assigment_relation)
    end

    # Returns all assigned tasks given to a user based on a particular task_type.
    def self.get_tasks_assigned_to_user_for_task_type(task_type, current_user)
        tto = current_user.task_type_options
        return nil if tto.empty?

        user_task_types = tto.pluck(:task_type_id)
        if user_task_types.include? task_type.id
            task_assigment_relation = TaskAssignment.where(assigned_to_id: [current_user.id, nil])
            task_type_relation = Task.joins(:task_assignments).where(task_type_id: task_type.id).
                                                        where(isVerified: nil).
                                                        where.not(percentComplete: 100).
                                                        where.not(isApproved: [nil, false]).
                                                        order("created_at DESC")

            return task_type_relation.merge(task_assigment_relation)
        else 
            return nil
        end
    end 

end
