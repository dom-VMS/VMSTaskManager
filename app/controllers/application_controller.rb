class ApplicationController < ActionController::Base
  before_action :require_login
  #before_action :get_current_user_role

  protect_from_forgery with: :exception
  include SessionsHelper
  include PublicActivity::StoreController
  include Pagy::Backend

  private 
  def require_login
    unless logged_in?
      flash.now[:error] = "You must be logged in to access this section."
      redirect_to login_path
    end
  end

end
