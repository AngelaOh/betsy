Rails.application.routes.draw do
  get "/products", to: "products#index", as: "products"
  resources :users, only: [:index, :show] do
    resources :products, expect: [:index]
  end

  get "orders/show"

  get "/users/current", to: "users#current", as: "current_user"
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "users#login", as: "auth_callback"

  delete "/logout", to: "users#destroy", as: "logout" # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
