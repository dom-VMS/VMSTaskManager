# Preview all emails at http://localhost:3000/rails/mailers/task_mailer
class TaskMailerPreview < ActionMailer::Preview

    #Sends an email to admin users when a new ticket has been created for their project.
    def new_ticket_created_admins
        TaskMailer.with(task: Task.first).new_ticket_created_admins
    end

    # Send Email to the user that created the ticket.
    def new_ticket_created_user
        TaskMailer.with(task: Task.first, user_id: User.first).new_ticket_created_user
    end

    # Sends email to user who filed the ticket when the ticket is approved.
    def ticket_approved
        TaskMailer.with(task: Task.first).ticket_approved
    end

    # Sends email to user who filed the ticket that their ticket has been disapproved.
    def ticket_rejected
        TaskMailer.with(task: Task.first, rejected_by: 'Domenico Aracri', feedback: 'Your ticket was declined because it is a test!').ticket_rejected
    end

end
