require 'my_utilities'
class Task < ApplicationRecord
    include ActiveModel::Dirty

    ## PublicActivity Set-up
    include PublicActivity::Model
    tracked

    ## config/initializers/task_constants.rb
    attr_accessor :PRIORITY
    attr_accessor :STATUS

    ## Carrierwave Set-up
    mount_uploaders :attachments, AttachmentUploader

    ## ActiveRecord Callbacks
    before_save :complete_tasks
    after_save :adjust_task_queue_for_completed_task 

    ## Active Record Associations
    belongs_to :task_type
    belongs_to :created_by, class_name: "User", optional: true
    belongs_to :completed_by, class_name: "User", optional: true
    belongs_to :verified_by, class_name: "User", optional: true
    has_one :reoccuring_task, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :logged_labors, dependent: :destroy
    #has_many :through association (users x task_queues x tasks)
    has_many :task_queues, dependent: :destroy
    has_many :users, through: :task_queues
    #has_many :through association (users x task_assignments x tasks)
    has_many :task_assignments, dependent: :destroy 
    has_many :users, through: :task_assignments, source: 'assigned_to'

    ## Scopes
    # Task.status
    scope :incomplete, -> { where(status: 1) }
    scope :in_progress, -> { where(status: 2) }
    scope :complete, -> { where(status: 3) }
    scope :on_hold, -> { where(status: 4) }
    scope :not_complete, -> { where(status: [nil, 1, 2, 4]) }
    # Task.priority
    scope :low_priority, -> { where(priority: 1) }
    scope :normal_priority, -> { where(priority: 2) }
    scope :high_priority, -> { where(priority: 3) }
    scope :urgent_priority, -> { where(priority: 4) }
    # Task.percentComplete
    scope :not_100_percent, -> { where(percentComplete: [nil, 0..99]) }
    scope :at_100_percent, -> { where(percentComplete: 100) }
    # Task.isApproved
    scope :isApproved, -> { where(isApproved: true) }
    scope :not_approved, -> { where(isApproved: [nil, false]) }
    scope :needs_approval, -> { where(isApproved: [nil]) }
    # Task.isVerified
    scope :isVerified, -> { where(isVerified: true) }
    scope :not_verified, -> { where(isVerified: [nil, false]) }
    # Task.task_type_id
    scope :project, -> (task_type) { where(task_type_id: task_type)}
    scope :recently_complete, -> {where("completed_date > ?", 14.days.ago)}

    ## Nested Attributes
    accepts_nested_attributes_for :task_assignments
    accepts_nested_attributes_for :reoccuring_task, reject_if: :all_blank
    
    ## ActiveRecord Validations
    validates_presence_of :task_type_id
    validates :created_by_id, numericality: true
    validate :logged_labors_must_be_present_if_required

    ## PublicActivity
    tracked owner: Proc.new{ |controller, model| controller.current_user }

    # If the due date for a task is altered, change the "next_date" field in ReoccuringTask
    def adjust_task_queue_for_completed_task
        if status == 3 && verification_required != true
            TaskQueue.remove_comepleted_task_from_queue(self)
        end
    end

    # If a user chooses to mark a task as complete w/o using the "Complete" button, this will assure all fields are set properly.
    def complete_tasks
        if status == 3
            self.percentComplete = 100
            self.completed_date = DateTime.now
        else
            self.completed_by_id = nil
            self.completed_date = nil
        end
    end

    # If a task requires logged_labors, validate a time entry has been added before a task is marked as "Complete"
    def logged_labors_must_be_present_if_required
        if logged_labor_required && self.logged_labors.present? == false && status == 3
            errors.add(:status, "can't be marked as complete until you record labor entries.")
            #redirect_to new_task_logged_labor(self)
        end
    end

    # Adds the uploaded file(s) to the array for attachments
    def self.add_file_attachment(task, new_attachments)
        attachments = task.attachments
        attachments += new_attachments
        task.attachments = attachments
    end

    # Returns all tasks assigned to a current user, combined with their task queue.
    def self.get_all_tasks_assigned_to_user(user)
        tasks = user.tasks.not_verified.not_complete.isApproved
        all_tasks = tasks.joins("LEFT OUTER JOIN task_queues ON task_queues.user_id = #{user.id} AND task_queues.task_id = tasks.id").select("tasks.*, task_queues.position").order(Arel.sql("ISNULL(task_queues.position), task_queues.position ASC;"))
        return all_tasks
    end

    # Returns all assigned tasks given to a user based on a particular task_type.
    def self.get_tasks_assigned_to_user_for_task_type(task_type, user)
        tasks = user.tasks.project(task_type).not_verified.not_complete.isApproved.order("created_at DESC")
    end

    # Retrieve all open tasks that a user is permitted to work on.
    def self.get_all_tasks_user_can_see(user)
        tasks = []
        tto = user.task_type_options
        if tto.empty?
            return nil
        else
            task_types = tto.pluck(:task_type_id)
            return (Task.not_verified.
                         not_100_percent.
                         not_complete.
                         isApproved.
                         project(task_types).
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
        task = Task.where(verification_required: true).not_verified.complete.project(task_types).order("updated_at DESC")
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
        task = Task.needs_approval.project(task_types).order("updated_at DESC")
    end

    # Allows an admin to place a comment in the task that is being declined to describe why it is being rejected.
    def self.insert_decline_feedback(task, decline_feedback_params, attachment_params)
        comment = task.comments.create(commenter_id: decline_feedback_params[:commenter_id], body: decline_feedback_params[:body], attachments: attachment_params[:attachments])
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
                Task.project(task_type).where(id: search)
            else
                Task.project(task_type).where('title LIKE ?', "%#{sanitize_sql_like(search)}%").not_complete
            end
        else
            Task.project(task_type)
        end
    end

    # Sends email to admin and users related to the ticket being filed.
    def self.send_ticket_email(task, user)
        #Send Email to Project Manager(s) if the priority is URGENT
        TaskMailer.with(task: task).new_ticket_created_admins.deliver_later if task.priority == 4 
        #Send Email to the user
        TaskMailer.with(task: task, user_id: user).new_ticket_created_user.deliver_later
    end

end
