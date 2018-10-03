Rails.application.routes.draw do
  get 'home/index'

  resources :tasks do
    resources :comments
  end

  resources :task_types do
    resources :tasks
  end

  resources :users
  
  root 'home#index'

end
