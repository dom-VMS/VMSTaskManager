class TaskTypesController < ApplicationController
    def index
        if search_params[:search]
            @task_types = TaskType.search(search_params[:search])
            if @task_types.nil? || @task_types.empty?
                @task_types = TaskType.all.order(:parent_id).order(:name)
                flash[:alert] = "Sorry, we couldn't find what you are searching for."
            end
        else
            #@task_types = TaskType.where(parent_id: nil).order('name ASC')
            parent_projects = TaskType.where(parent_id: nil).order('name ASC')
            @task_types = TaskType.get_all_projects_in_order(parent_projects)
        end
    end
    
    def show
        @task_type = find_task_type
        @task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type)
        @pagy_all_tasks, @tasks = pagy(@task_type.tasks.where(isApproved: true).where.not(status: 3).or(@task_type.tasks.where(status: nil).where(isApproved: true)).order("created_at DESC"), 
                                        page_param: :page_all_tasks, 
                                        params: { active_tab: 'all_tasks' })
        @pagy_tasks_assigned_to_user, @tasks_assigned_to_user = pagy(Task.get_tasks_assigned_to_user_for_task_type(@task_type, current_user), 
                                        page_param: :page_tasks_assigned_to_user, 
                                        params: { active_tab: 'tasks_assigned_to_user' }) unless @task_type_option.nil?
        @tasks_recently_complete = @task_type.tasks.where(status: 3).where("updated_at > ?", 14.days.ago)
        unless search_params[:search].blank?
            @tasks_search = Task.search_with_task_type(search_params[:search], @task_type)
            if @tasks_search.nil? || @tasks_search.empty?
                @tasks_search = nil
                flash[:notice] = "Sorry, we couldn't find what you are searching for."
            end
        else
            @tasks_search = nil
        end
        @users = TaskType.get_users(@task_type)
    end
    
    def new
        @task_type = TaskType.new
    end

    def edit
        @task_type = find_task_type
        @children = @task_type.children
        @task_type_options = @task_type.task_type_options

        if @task_type_options.present?
            current_user_task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type)
            if current_user_task_type_option.nil? || current_user_task_type_option.isAdmin == false 
                flash[:error] = "Sorry, but you do not have permission to edit #{@task_type.name}."
                redirect_to @task_type
            end
        end
    end

    def create
        @task_type = TaskType.new(task_type_params)
 
        if @task_type.save
            flash[:success] = "#{@task_type.name} has been created!"
            redirect_to edit_task_type_path(@task_type)
        else
            flash[:danger] = "Oops! Something went wrong."
            render 'new'
        end
    end

    def update
        @task_type = find_task_type
       
        if @task_type.update(task_type_params)
          flash[:success] = "#{@task_type.name} has been updated!"
          redirect_to @task_type
        else
          flash[:danger] = "Oops! Something went wrong. #{@task_type.name} wasn't updated."
          render 'edit'
        end
    end

    def destroy
        @task_type = find_task_type
        #task_type_option = TaskTypeOption.get_task_type_specific_options(current_user, @task_type)
        #if !@task_type.task_type_options.present?
            destroy_task_type
        #elsif (task_type_option.isAdmin && task_type_option.can_delete) 
        #    destroy_task_type
        #else
        #    flash[:danger] = "You are not permitted to delete this project."
        #    redirect_to edit_task_type_path(@task_type)
       # end
    end

    def remove_child
        child = TaskType.find(params[:id])
        parent = TaskType.find(child.parent.id)

        if child.update(parent_id: nil)
            flash[:success] = "#{child.name} has been removed from #{parent.name}."            
            redirect_to edit_task_type_path(parent)
        else
            flash[:danger] = "Something went wrong. #{child.name} was not removed from #{parent.name} "
            redirect_to edit_task_type_path(@task_type)
        end
    end

    def destroy_task_type
        @task_type.destroy
        if @task_type.destroyed?
            flash[:success] = "#{@task_type.name} has been removed."
            redirect_to task_types_path
        else
            flash[:danger] = "Something went wrong."
            redirect_to edit_task_type_path(@task_type)
        end
    end

    private
      def task_type_params
        params.require(:task_type).permit(:task_type_id, :name, :description, :search, :parent_id)
      end

      def search_params
        params.permit(:search)
      end

      def find_task_type
        TaskType.find(params[:id])
      end
end
