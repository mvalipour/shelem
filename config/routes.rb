Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  resources :games, only: [:new, :create, :show]
  resources :user_names, only: [:index, :create]

  namespace :api do
    resources :games, only: [:show] do
      post 'start', to: 'games#start', as: :start
    end
  end
end
