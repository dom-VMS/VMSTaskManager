class TaskMailer < ApplicationMailer
    default from: 'varlandmetalservice@gmail.com'
 
    #Sends an email to admin users when a new ticket has been created for their project.
    def new_ticket_created_admins
        @task = params[:task]
        @task_type = @task.task_type
        @url = task_url(@task)
        admins = TaskType.get_admins(@task_type)
        admins.each do |admin|
            puts "Sending email..."
            mail(to: admin.email, subject: 'Task Manager - A New Ticket has Been Filed.')
        end
    end 

    #Sends an email to user who filed the Ticket
    def new_ticket_created_user
        @task = params[:task]
        @task_type = @task.task_type
        @url = task_url(@task)
        @user = User.find_by_id(params[:user_id])
        puts "Sending email..."
        mail(to: @user.email, subject: 'Task Manager - Your Ticket has Been Filed!')
    end 

end
