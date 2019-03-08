Rails.application.routes.draw do
  get 'activities/index'

  get '/home', to: 'home#index'
  get 'home/welcome'
  get '/admin',   to: 'admin#index'
  get 'errors/not_signed_in'

  # Sessions
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :activities

  resources :tasks do
    resources :comments, :only => [:create, :destroy]
    resources :logged_labors, :only => [:index, :new, :create]
    resources :file_attachments, :only => [:create, :destroy]
    resources :attachments, :only => [:create, :destroy]
    resources :task_assignments, :only => [:new, :create, :destroy]
  end
  
  # Tasks and Tickets
  get   '/ticket',   to: 'tasks#ticket'
  post  '/ticket',   to: 'tasks#create_ticket' #<-- I don't think this actually goes there
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
    resources :task_type_options , :path => "roles", :only => [:new, :create, :destroy] 
  end
  resources :task_type_options , :path => "roles", :only => [:index, :edit, :update, :show] do
    resources :user_groups, :only => [:new, :create]
  end
  resources :user_groups, :only => [:delete]
  
  resources :users do
    resources :user_groups
  end
  
  root 'home#welcome'
end
