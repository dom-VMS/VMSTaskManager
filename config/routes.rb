Rails.application.routes.draw do
  get 'home/index'

  resources :tasks do
    resources :comments
  end

  resources :task_types do
    resources :tasks
  end
  
  root 'home#index'

end
