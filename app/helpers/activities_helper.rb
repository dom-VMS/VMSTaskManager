module ActivitiesHelper
    # Used to track activities on a specific task.
    def self.get_activities(task)
        activities_by_trackable = PublicActivity::Activity.where("trackable_type = ? and trackable_id = ?", "Task", task.id)
        activities_by_recipient = PublicActivity::Activity.where("recipient_type = ? and recipient_id = ?", "Task", task.id)
        return activities = (activities_by_trackable + activities_by_recipient).sort_by{|activity| activity.created_at}
    end
end
