Rails.application.routes.draw do
  get 'home/index'

  resources :tasks do
    resources :comments
  end
  
  root 'home#index'

end
