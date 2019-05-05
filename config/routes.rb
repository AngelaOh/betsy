Rails.application.routes.draw do
  root "products#root"

  resources :users, only: [:index, :show] do
    resources :products, except: [:index, :show]
  end

  get "/products", to: "products#index", as: "products"
  get "/products/:id", to: "products#show", as: "product"

  # post get "/products/:id", to: "products#new_order_item", as: "add_item" # this would create a new orderitem that would be added to cart
  post "/products/:id", to: "orders#new_order_item", as: "add_item" # this would create a new orderitem that would be added to cart
  get "/cart", to: "orders#cart", as: "cart" # this shows all order items in the cart
  get "/orders/new", to: "orders#new", as: "checkout_form"
  get "/orders/:id", to: "orders#show", as: "order" # this would show the confirmation page for one order that was submitted

  get "/users/current", to: "users#current", as: "current_user"
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "users#login", as: "auth_callback"

  delete "/logout", to: "users#destroy", as: "logout" # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
