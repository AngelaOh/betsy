Rails.application.routes.draw do
  root "products#root"

  resources :users, only: [:index, :show] do
    resources :products, except: [:index, :show]
  end

  get "/products", to: "products#index", as: "products"
  get "/products/:id", to: "products#show", as: "product"

  get "/orders/:id", to: "orders#show", as: "order"

  get "/users/current", to: "users#current", as: "current_user"
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "users#login", as: "auth_callback"

  delete "/logout", to: "users#destroy", as: "logout" # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
