class UserMailer < ApplicationMailer
    default from: 'varlandmetalservice@gmail.com'
 
    def welcome_email
        @user = params[:user]
        @url  = 'http://localhost:3000/login'
        mail(to: @user.email, subject: 'TEST: Welcome to VMS - ProjectManager')
    end    
end
