Rails.application.routes.draw do
  get 'home/login'
  get 'home/index'
  get '/admin' => 'admin#index'

  resources :tasks do
    resources :comments
  end

  resources :task_types do
    resources :task_type_options 
  end

  resources :user_groups
  resources :users do
    resources :user_groups
  end
  
  root 'home#login'


end
