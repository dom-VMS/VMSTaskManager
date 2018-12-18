class HomeController < ApplicationController
  def index
    if logged_in?
      @task = Task.get_all_tasks_assigned_to_user(current_user)
      @reoccuring_event = ReoccuringEvent.where(next_date: (Date.today)..((Date.today).advance(:days => 7)))
    else
      render partial: 'errors/not_signed_in'
    end
  end

  def ticket
  end
end
