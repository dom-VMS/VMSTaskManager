Rails.application.routes.draw do
  get 'home/index'
  get '/admin' => 'admin#index'

  resources :tasks do
    resources :comments
  end

  resources :task_types do
    resources :tasks
    resources :task_type_options
  end

  resources :users
  
  root 'home#index'


end
