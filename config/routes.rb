Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'
  resources :games, only: [:new, :create, :show] do
    %i(join deal start_bidding bid pass trump start_game play restart).each do |action|
      post action, to: "games##{action}", as: action
    end

    get :data, to: 'games#data', as: :data
  end
  resources :user_names, only: [:index, :create]
end
