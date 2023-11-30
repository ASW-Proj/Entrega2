Rails.application.routes.draw do
  get 'pages/home'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check # No esborrar

  # Communities
  get "/communities", to: "communities#index"
  post "/communities", to: "communities#create"

  get "/users", to: "users#index"
  post "/users", to: "users#create"

  get "/comments", to: "comments#index"
  post "/comments", to: "comments#create"


  root 'comments#index' #, defaults: { format: :html }
end
