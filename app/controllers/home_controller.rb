class HomeController < ApplicationController
  def index
    if logged_in?
    else
      render partial: 'errors/not_signed_in'
    end
  end

  def ticket
  end
end
