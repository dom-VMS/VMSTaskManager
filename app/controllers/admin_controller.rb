class AdminController < ApplicationController
    
    def index
        unless isAdmin?
            flash[:error] = "You are not an admin. You may not enter."
            redirect_back(fallback_location: home_path)
        else
            flash[:error] = "You are not an admin. You may not enter."
            redirect_back(fallback_location: home_path)
        end
    end

end
