Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :topics, only: [:index, :show, :create, :destroy] do
        resources :posts, only: [:index, :create]
      end
    end
  end
end
