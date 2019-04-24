class ContentsController < ApplicationController
  skip_before_action :require_login
  
  def getting_started
  end
end
