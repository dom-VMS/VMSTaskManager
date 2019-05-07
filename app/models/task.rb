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
    has_one :reoccuring_task, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :logged_labors, dependent: :destroy

    #has_many :through association (users x task_queues x tasks)
    has_many :task_queues, dependent: :destroy
    has_many :users, through: :task_queues

    #has_many :through association (users x task_assignments x tasks)
    has_many :task_assignments, dependent: :destroy 
    has_many :users, through: :task_assignments, source: 'assigned_to'

    accepts_nested_attributes_for :task_assignments
    accepts_nested_attributes_for :reoccuring_task, reject_if: :all_blank
    
    #validates :created_by_id_exists
    validates_presence_of :task_type_id
    validates :created_by_id, numericality: true

    tracked owner: Proc.new{ |controller, model| controller.current_user }

    # Adds the uploaded file(s) to the array for attachments
    def self.add_file_attachment(task, new_attachments)
        attachments = task.attachments
        attachments += new_attachments
        task.attachments = attachments
    end

    # Returns all tasks assigned to a current user, combined with their task queue.
    def self.get_all_tasks_assigned_to_user(user)
        tasks = user.tasks.where(isVerified: [nil, false]).where.not(status: 3).where.not(isApproved: [nil, false])
        all_tasks = tasks.joins("LEFT OUTER JOIN task_queues ON task_queues.user_id = #{user.id} AND task_queues.task_id = tasks.id").select("tasks.*, task_queues.position").order(Arel.sql("ISNULL(task_queues.position), task_queues.position ASC;"))
        return all_tasks
    end

    # Returns all assigned tasks given to a user based on a particular task_type.
    def self.get_tasks_assigned_to_user_for_task_type(task_type, user)
        tasks = user.tasks.where(task_type_id: task_type).where(isVerified: [nil, false]).where.not(status: 3).where.not(isApproved: [nil, false]).order("created_at DESC")
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
        task_types = TaskType.find(user.task_type_options.where(can_verify: true).pluck(:task_type_id))
        unpermitted_task_types = TaskType.find(user.task_type_options.where(can_verify: false).pluck(:task_type_id))
        task_types.each do |task_type|
          if task_type.children.any?
            task_type.children.each do |child|
              task_types.append(child) unless ((task_types.any? {|task_type| task_type == child}) || (unpermitted_task_types.any? {|unpermitted| unpermitted == child}))
            end
          end
        end  
        task = Task.where(isVerified: [nil, false]).where(status: 3).where(task_type_id: [task_types]).order("updated_at DESC")
    end

    # Retrieve all open tasks that a user is permitted to approve.
    def self.get_all_tickets_user_can_approve(user)
        task_types = TaskType.find(user.task_type_options.where(can_approve: true).pluck(:task_type_id))
        unpermitted_task_types = TaskType.find(user.task_type_options.where(can_approve: false).pluck(:task_type_id))
        task_types.each do |task_type|
            if task_type.children.any?
                task_type.children.each do |child|
                    task_types.append(child) unless ((task_types.any? {|task_type| task_type == child}) || (unpermitted_task_types.any? {|unpermitted| unpermitted == child}))
                end
            end
        end  
        task = Task.where(isApproved: [nil]).where(task_type_id: [task_types]).order("updated_at DESC")
    end

    # Allows an admin to place a comment in the task that is being declined to describe why it is being rejected.
    def self.insert_decline_feedback(task, feedback_params, attachment_params)
        comment = task.comments.create(commenter: feedback_params[:commenter], body: feedback_params[:body], attachments: attachment_params[:attachments])
        comment.save!
    end

    # Locates an attachment at a gievn index and removes it from the database.
    def self.remove_attachment_at_index(task, index)     
        attachments = task.attachments # copy the array
        attachments.delete_at(index)
        task.attachments = attachments
        task.remove_attachments! if attachments.empty? # Used when deleting the last remaining attachment. Will not delte otherwise.
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

    # Sends email to admin and users related to the ticket being filed.
    def self.send_ticket_email(task, user)
        #Send Email to Project Manager(s)
        TaskMailer.with(task: @task).new_ticket_created_admins.deliver_later
        #Send Email to the user
        TaskMailer.with(task: @task, user_id: user).new_ticket_created_user.deliver_later
    end

end
