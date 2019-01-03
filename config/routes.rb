Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  resources :games, only: [:new, :create, :show] do
    post 'join', to: 'games#join', as: :join
  end
  resources :user_names, only: [:index, :create]
end
