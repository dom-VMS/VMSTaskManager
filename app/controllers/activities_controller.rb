class ActivitiesController < ApplicationController
  def index
    @pagy, @activities = pagy(PublicActivity::Activity.includes(:owner).includes(:trackable).where("created_at > ?", 14.days.ago).
                                                       order("created_at desc"))
    
  end
end
