Rails.application.routes.draw do
  resources :users, only: [:index, :show] do
    resources :products
  end

  get "orders/show"

  get "/users/current", to: "users#current", as: "current_user"
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "users#create", as: "auth_callback"
  delete "/logout", to: "users#destroy", as: "logout" # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
