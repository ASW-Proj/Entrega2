class UsersController < ApplicationController

    # GET /users
    def index
        @users = User.all.order(name: :asc)

        users_json = @users.map do |user|
            {
              id:  user.id,
              username: user.username,
              name: user.name,
              bio: user.bio,
              created_at: user.created_at,
              updated_at: user.updated_at,
              api_key: user.api_key,
            }
        end

        render json: { users: users_json }, status: :ok
    end



     # GET /users/:id
      def show
        @user = User.find(params[:id])

        user_json = {
          id: @user.id,
          username: @user.username,
          name: @user.name,
          bio: @user.bio,
          user_avatar: @user.user_avatar.attached? ? url_for(@user.user_avatar) : nil,
          user_banner: @user.user_banner.attached? ? url_for(@user.user_banner) : nil,
          created_at: @user.created_at,
          updated_at: @user.updated_at,
          api_key: @user.api_key
        }

        render json: { user: user_json }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      def showByToken
        @user = User.find(params[:api_key])

        user_json = {
          id: @user.id,
          username: @user.username,
          name: @user.name,
          bio: @user.bio,
          user_avatar: @user.user_avatar.attached? ? url_for(@user.user_avatar) : nil,
          user_banner: @user.user_banner.attached? ? url_for(@user.user_banner) : nil,
          created_at: @user.created_at,
          updated_at: @user.updated_at,
          api_key: @user.api_key
        }

        render json: { user: user_json }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
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
                id: @user.id,
                username: @user.username,
                name:  @user.name,
                bio: @user.bio,
                email: @user.email,
                created_at: @user.created_at,
                updated_at: @user.updated_at,
                api_key: @user.api_key
              }

            }, status: :created
        else
            render json: {
              errors: @user.errors.full_messages
            }, status: :unprocessable_entity
        end
    end



    # DELETE /users/1
        def destroy
          if @user = @current_user

            if @user.destroy
              render json: { message: 'User deleted successfully' }, status: :ok
            else
              render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
            end
          end
        end



# PUT /users/1
      def update
        if @user = @current_user

          if @user.update(user_params)
            render json: {
              message: 'User updated successfully',
              user: {
                  id: @user.id,
                  username: @user.username,
                  name:  @user.name,
                  bio: @user.bio,
                  email: @user.email,
                  created_at: @user.created_at,
                  updated_at: @user.updated_at,
                  api_key: @user.api_key
                }
            }, status: :ok
          else
            render json: {
              errors: @user.errors.full_messages
            }, status: :unprocessable_entity
          end
        end
      end

    private
        # Only allow a list of trusted parameters through.
        def user_params
            params.require(:user).permit(:username, :name, :bio, :user_avatar, :user_banner, :email)
        end
end