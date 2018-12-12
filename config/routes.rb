Rails.application.routes.draw do
  get 'activities/index'

  get 'home/index'
  get 'home/welcome'
  get '/admin',   to: 'admin#index'
  get '/admin/task_types',   to: 'admin#task_types'
  get 'admin/task_types',   to: 'task_type#index'
  get 'errors/not_signed_in'

  # Sessions
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :activities

  resources :tasks do
    resources :comments, :only => [:create, :destroy]
    resources :logged_labors
    resources :file_attachments, :only => [:create, :destroy]
  end

  # Tasks and Tickets
  get   '/ticket',   to: 'tasks#ticket'
  post  '/ticket',   to: 'tasks#create_ticket'
  get   '/review',   to: 'tasks#review'
  patch '/review',   to: 'tasks#update_ticket'
  put   '/review',   to: 'tasks#update_ticket'
  get   '/verify',   to: 'tasks#verify'
  patch '/verify',   to: 'tasks#update_ticket'
  put   '/verify',   to: 'tasks#update_ticket'

  resources :logged_labors
  resources :task_types
  resources :task_type_options 
  resources :user_groups
  
  resources :users do
    resources :user_groups
  end
  
  root 'home#welcome'
end
