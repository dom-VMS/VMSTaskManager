class ActivitiesController < ApplicationController
  def index
    @pagy, @activities = pagy(PublicActivity::Activity.where("created_at > ?", 14.days.ago).
                                                       order("created_at desc"))
    
  end
end
