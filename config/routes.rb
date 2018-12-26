Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  resources :games, only: [:new, :create, :show] do
    post 'start', to: 'games#start', as: :start 
    post 'finish', to: 'games#finish', as: :finish 
  end
  resources :user_names, only: [:index, :create]
end
