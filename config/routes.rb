Rails.application.routes.draw do
  # get 'categories/index'
  # get 'categories/show'
  root "products#root"

  resources :users, only: [:index, :show] do
    resources :products, except: [:show]
  end

  resources :categories, only: [:index, :show]

  get "/products", to: "products#index", as: "products"
  get "/products/:id", to: "products#show", as: "product"
  patch "/users/:user_id/products/:id/retire", to: "products#retire", as: "product_retire"

  # post get "/products/:id", to: "products#new_order_item", as: "add_item" # this would create a new orderitem that would be added to cart
  patch "/products/:id", to: "orders#update_order_item_quantity", as: "update_quantity"
  post "/products/:id", to: "orders#new_order_item", as: "add_item" # this would create a new orderitem that would be added to cart
  get "/cart", to: "orders#cart", as: "cart" # this shows all order items in the cart
  get "/orders/new", to: "orders#new", as: "checkout_form"
  get "/orders/:id", to: "orders#show", as: "order" # this would show the confirmation page for one order that was submitted
  patch "/orders/:id", to: "orders#update", as: "order_update"
  patch "/orders/:id/ship", to: "orders#ship_order", as: "ship_order"
  delete "/products/:id", to: "orders#destroy", as: "delete_item"

  get "/users/current", to: "users#current", as: "current_user"
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "users#login", as: "auth_callback"

  delete "/logout", to: "users#destroy", as: "logout" # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
