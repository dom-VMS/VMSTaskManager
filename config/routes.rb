Rails.application.routes.draw do
  get 'activities/index'

  get 'home/login'
  get 'home/index'
  get 'home/ticket'
  get 'home/welcom'
  get '/admin' => 'admin#index'
  get '/admin/task_types' => 'admin#task_types'
  get 'admin/task_types' => 'task_type#index'
  get 'errors/not_signed_in'

  #sessions
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :activities

  resources :tasks do
    resources :comments, :only => [:create, :destroy]
    resources :logged_labors
    resources :file_attachments, :only => [:create, :destroy]
  end

  resources :logged_labors

  resources :task_types

  
  resources :task_type_options 
  resources :user_groups
  
  resources :users do
    resources :user_groups
  end
  
  root 'home#welcome'
end
