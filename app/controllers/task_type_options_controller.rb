class TaskTypeOptionsController < ApplicationController
    before_action :find_task_type_option, only: [:show, :edit, :update, :destroy]
    before_action :find_task_type, except: [:index, :destroy]

    def index
        @task_types = TaskType.all
        @task_type_options = TaskTypeOption.all
    end

    def show
        @current_user_task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type)
    end

    def new
        current_task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type)
        unless @task_type.task_type_options.empty? 
            if current_task_type_option.nil? || current_task_type_option.isAdmin == false
                flash[:error] = "Sorry, but you do not have permission to create #{@task_type.name} roles."
                redirect_to task_type_path(@task_type)
            else
                @task_type_option = TaskTypeOption.new
            end
        else
            #In the case there are no roles defined for the TaskType, allow a user to create one.
            @task_type_option = TaskTypeOption.new
        end
    end

    def create
        @task_type_option = TaskTypeOption.new(task_type_options_params)

        if @task_type_option.save
            redirect_to task_type_task_type_option_path(@task_type, @task_type_option)
        else
            render 'new'
        end
    end

    def edit
    end

    def update
        if @task_type_option.update(task_type_options_params)
            redirect_to task_type_task_type_option_path(@task_type, @task_type_option)
        else
            render 'edit'
        end
    end
    def destroy
        @task_type = @task_type_option.task_type
        @task_type_option.destroy

        redirect_to task_type_path(@task_type)
    end

    private
    def task_type_options_params
      params.require(:task_type_option).permit(:name,
                                               :isAdmin,
                                               :can_view,
                                               :can_create,
                                               :can_update,
                                               :can_delete,
                                               :can_approve,
                                               :can_verify,
                                               :can_comment,
                                               :can_log_labor,
                                               :can_view_cost,
                                               :task_type_id)
    end

    def find_task_type
        @task_type = TaskType.find_by_id(params[:task_type_id])
    end

    def find_task_type_option
        @task_type_option = TaskTypeOption.find(params[:id])
    end

end
