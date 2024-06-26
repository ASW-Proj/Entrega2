Rails.application.routes.draw do

    mount Rswag::Api::Engine => '/api-docs'
    mount Rswag::Ui::Engine => '/api-docs'

    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
    # Can be used by load balancers and uptime monitors to verify that the app is live.
    get "up" => "rails/health#show", as: :rails_health_check

    # Communities
    get "/communities", to: "communities#index"
    post "/communities", to: "communities#create"
    get "/communities/:id", to: "communities#show"
    delete "/communities/:id", to: "communities#destroy"
    put '/communities/:id', to: 'communities#update'


    # Posts
    get "/posts", to: "posts#index"
    post "/posts", to: "posts#create"
    get "/posts/:id", to: "posts#show"
    delete "/posts/:id", to: "posts#destroy"
    put '/posts/:id', to: 'posts#update'

    # Users
    get "/users", to: "users#index"
    post "/users", to: "users#create"
    get "/users/:id", to: "users#show"
    delete "/users/:id", to: "users#destroy"
    put '/users/:id', to: 'users#update'
    get "/user/:api_key", to: "users#showByToken"


    #Comments
    get "/comments", to: "comments#index"
    post "/comments", to: "comments#create"
    get "/comments/:id", to: "comments#show"
    delete "/comments/:id", to: "comments#destroy"
    put '/comments/:id', to: 'comments#update'

    # Subscriptions
    post "/community/:community_id/subscribe", to: "subscriptions#subscribe"
    delete "/community/:community_id/subscribe", to: "subscriptions#unsubscribe" #He cambiado subscribe por unsubscribe para la cohesion

    # Saved posts
    post "/post/:post_id/save", to: "saved_posts#save"
    delete "/post/:post_id/save", to: "saved_posts#unsave"


    # Saved comments
    post "/comment/:comment_id/save", to: "saved_comments#save"
    delete "/comment/:comment_id/save", to: "saved_comments#unsave"

    # Liked posts
    post "/post/:post_id/like", to: "post_likes#like"
    delete "/post/:post_id/like", to: "post_likes#unlike"

    # Liked comments
    post "/comment/:comment_id/like", to: "comment_likes#like"
    delete "/comment/:comment_id/like", to: "comment_likes#unlike"


end
