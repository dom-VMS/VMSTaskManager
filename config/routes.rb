Rails.application.routes.draw do
  mount RlegacyAdmin::Engine, at: "/admin"
  get 'activities/index'
  get 'contents/getting_started'
  get 'errors/not_signed_in'
  get '/home', to: 'home#index'
  get 'home/welcome'

  # Sessions
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :activities

  resources :tasks, :only => [:create, :destroy, :show, :update, :edit] do
    resources :comments, :only => [:create, :destroy]
    resources :logged_labors, :only => [:index, :new, :create]
    resources :file_attachments, :only => [:create, :destroy]
    resources :attachments, :only => [:create, :destroy]
    resources :task_assignments, :only => [:new, :create, :destroy]
  end
  
  # Tasks and Tickets
  get   '/ticket',   to: 'tasks#ticket'
  get   '/review',   to: 'tasks#review'
  patch '/review',   to: 'tasks#update_ticket'
  put   '/review',   to: 'tasks#update_ticket'
  get   '/verify',   to: 'tasks#verify'
  patch '/verify',   to: 'tasks#update_ticket'
  put   '/verify',   to: 'tasks#update_ticket'

  resources :task_types, :path => "projects" do
    resources :user, :only => [] do 
      resources :task_queues
    end
    resources :tasks, :only => [:new, :create]
    resources :task_type_options , :path => "roles" do
      resources :user_groups, :path => "user-assignment", :only => [:new, :create]
    end
    member do
      patch :remove_child
      put :remove_child
    end
  end
  
  resources :task_type_options , :path => "roles", :only => [:index]
  resources :user_groups, :path => "user-assignment", :only => [:destroy]
  
  resources :users 
  
  root 'home#welcome'
end
