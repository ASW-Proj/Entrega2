class PostLikesController < ApplicationController
    
    
      before_action :authenticate_user, if: -> { %w[post put delete].include?(request.method.downcase) }
    attr_reader :current_user

    # POST /post/:post_id/like/:user_id
    def like
        if post.post_likes.find_by(user: user).nil?
            @liked_post = PostLike.new(post: post, user: user, positive: positive)

            if @liked_post.save
                render json: {
                    message: 'Liked successfully',
                    positive: @liked_post.positive,
                    user_id: @liked_post.user.id,
                    post_id: @liked_post.post.id
                }, status: :ok
            else
                render json: {
                    errors: @liked_post.errors.full_messages
                }, status: :unprocessable_entity
            end
        else
            @liked_post = post.post_likes.find_by(user: user)

            if @liked_post.update(positive: positive)
                render json: {
                    message: 'Like updated successfully',
                    positive: @liked_post.positive,
                    user_id: @liked_post.user.id,
                    post_id: @liked_post.post.id
                }, status: :ok
            else
                render json: {
                    errors: @liked_post.errors.full_messages
                }, status: :unprocessable_entity
            end
        end
    end

    # DELETE /post/:post_id/like/:user_id
    def unlike
        @liked_post = post.post_likes.find_by(user: user)

        if !@liked_post.nil?
            @liked_post.destroy!
            render json: {
                message: 'The post is no longer liked',
            }, status: :ok
        else
            render json: {
                errors: ['The post was not liked']
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
    def positive
        params.require(:positive)
    end
end