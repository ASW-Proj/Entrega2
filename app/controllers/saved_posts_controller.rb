class SavedPostsController < ApplicationController

          before_action :authenticate_user, if: -> { %w[post put delete].include?(request.method.downcase) }

    # POST /post/:post_id/save/:user_id
    def save
        @saved_post = SavedPost.new(post: post, user: user)

        if @saved_post.save
            render json: {
                message: 'Saved successfully',
                user_id: @saved_post.user.id,
                post_id: @saved_post.post.id
            }, status: :ok
        else
            render json: {
                errors: @saved_post.errors.full_messages
            }, status: :unprocessable_entity
        end
    end

    # DELETE /post/:post_id/save/:user_id
    def unsave
        @saved_post = post.saved_posts.find_by(user: user)

        if !@saved_post.nil?
            @saved_post.destroy!
            render json: {
                message: 'The post is no longer saved',
            }, status: :ok
        else
            render json: {
                errors: ['The post was not saved']
            }, status: :unprocessable_entity
        end
    end

    # Post getter
    def post
        @post ||= Post.find(params[:post_id])
    end

    # User getter
    def user
        @user ||= User.find(params[:user_id])
    end


     private
        def authenticate_user
            token = extract_token_from_request
            if token_valid?(token)
                @current_user = User.find_by(api_key: token)
            else
                render json: { error: 'Unauthorized' }, status: :unauthorized
            end
        end

        def extract_token_from_request
            header = request.headers['Authorization']
            header&.split(' ')&.last
        end

        def token_valid?(token)
            !token.nil? && !token.empty? && User.exists?(api_key: token)
        end
end