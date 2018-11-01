Rails.application.routes.draw do
  get 'home/login'
  get 'home/index'
  get '/admin' => 'admin#index'
  get '/admin/task_types' => 'admin#task_types'

  resources :tasks do
    resources :comments, :only => [:create, :destroy]
    resources :logged_labors
    resources :file_attachments, :only => [:create, :destroy]
  end

  resources :logged_labors

  resources :task_types

  get 'admin/task_types' => 'task_type#index'
  resources :task_type_options 
  resources :user_groups
  
  resources :users do
    resources :user_groups
  end
  
  root 'home#login'


end
