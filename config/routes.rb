Rails.application.routes.draw do
  resources :users, only: [:index, :show] do
    resources :products, except: [:index, :show]
  end

  get "/products", to: "products#index", as: "products"
  get "/products/:id", to: "products#show", as: "product"

  get "/orders/cart", to: "orders#cart", as: "cart" # this shows all order items in the cart
  get "/orders/:id", to: "orders#show", as: "order" # this would show the confirmation page for one order that was submitted
  post get "/products/:id", to: "orders#new_item", as: "add_item" # this would create a new orderitem that would be added to cart

  get "/users/current", to: "users#current", as: "current_user"
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "users#login", as: "auth_callback"

  delete "/logout", to: "users#destroy", as: "logout" # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
