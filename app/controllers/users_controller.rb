class UsersController < ApplicationController

    # GET /users
    def index
        @users = User.all.order(name: :asc)

        users_json = @users.map do |user|
            {
              user_id:  user.id,
              username: user.username,
              name: user.name,
              bio: user.bio,
              created_at: user.created_at,
              updated_at: user.updated_at,

            }
        end

        render json: { users: users_json }, status: :ok
    end



    # POST /users
    def create
        # Creates an instance of user
        @user = User.new(user_params)

        # Save it in DB
        if @user.save
            render json: {
              message: 'User created successfully',
              user: {
                username: @user.username,
                name:  @user.name,
                bio: @user.bio,
                mail: @user.email,
                user_avatar: @user.user_avatar ,
                user_banner: @user.user_banner,
                created_at: @user.created_at,
                updated_at: @user.updated_at
              }
            }, status: :created
        else
            render json: {
              errors: @user.errors.full_messages
            }, status: :unprocessable_entity
        end
    end

    private
        # Only allow a list of trusted parameters through.
        def user_params
            params.permit(:user).permit(:username, :name, :bio, :user_avatar, :user_banner, :email)
        end
end