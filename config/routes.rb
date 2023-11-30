Rails.application.routes.draw do

    mount Rswag::Api::Engine => '/api-docs'
    mount Rswag::Ui::Engine => '/api-docs'

    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check # No esborrar

    # Communities
    get "/communities", to: "communities#index"
    post "/communities", to: "communities#create"

    # Posts
    post "/posts", to: "posts#create"

    # Users
    get "/users", to: "users#index"
    post "/users", to: "users#create"
    get "/users/:id", to: "users#show"
    
  
    #Comments
    get "/comments/:order", to: "comments#index"
    post "/comments", to: "comments#create"
    get "/comments/:id", to: "comments#show"
  
    # Subscriptions
    post "/community/:community_id/subscribe/:user_id", to: "subscriptions#subscribe"
    delete "/community/:community_id/unsubscribe/:user_id", to: "subscriptions#unsubscribe"

    # Saved posts
    post "/post/:post_id/save/:user_id", to: "saved_posts#save"
    delete "/post/:post_id/save/:user_id", to: "saved_posts#unsave"


    # Saved comments
    post "/comment/:comment_id/save/:user_id", to: "saved_comments#save"
    delete "/comment/:comment_id/save/:user_id", to: "saved_comments#unsave"

    # Liked posts
    post "/post/:post_id/like/:user_id", to: "post_likes#like"
    delete "/post/:post_id/like/:user_id", to: "post_likes#unlike"

    # Liked comments
    post "/comment/:comment_id/like/:user_id", to: "comment_likes#like"
    delete "/comment/:comment_id/like/:user_id", to: "comment_likes#unlike"


end
