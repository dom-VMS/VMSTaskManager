class ApplicationController < ActionController::Base
  before_action :require_login

  protect_from_forgery with: :exception
  include SessionsHelper
  include PublicActivity::StoreController
  include Pagy::Backend

  private 
  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section."
      redirect_to login_path
    end
  end

end
