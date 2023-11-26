class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all.order(name: :asc)

    users_json = @users.map do |user|
      {
        id: user.id,
        username: user.username,
        email: user.email,
        avatar: user.avatar.attached? ? url_for(user.avatar) : nil,
        created_at: user.created_at,
        updated_at: user.updated_at
      }
    end

    render json: { users: users_json }, status: :ok
  end

  # GET /users/1
  def show
    render json: {
      id: @user.id,
      username: @user.username,
      email: @user.email,
      avatar: @user.avatar.attached? ? url_for(@user.avatar) : nil,
      created_at: @user.created_at,
      updated_at: @user.updated_at
    }, status: :ok
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: {
        message: 'User created successfully',
        user: {
          id: @user.id,
          username: @user.username,
          email: @user.email,
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

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: {
        message: 'User updated successfully',
        user: {
          id: @user.id,
          username: @user.username,
          email: @user.email,
          created_at: @user.created_at,
          updated_at: @user.updated_at
        }
      }, status: :ok
    else
      render json: {
        errors: @user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    render json: { message: 'User deleted successfully' }, status: :ok
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:username, :email, :avatar)
  end
end
