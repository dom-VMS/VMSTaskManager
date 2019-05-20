class ActivitiesController < ApplicationController
  def index
    @pagy, @activities = pagy(PublicActivity::Activity.includes(:owner).includes(:trackable).includes(:recipient).where("created_at > ?", 14.days.ago).
                                                       order("created_at desc"))
    
  end
end
