class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  include PublicActivity::StoreController
  include Pagy::Backend
  #include ActionController::MimeResponds
end
