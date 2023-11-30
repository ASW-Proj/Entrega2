class SavedPostsController < ApplicationController
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
end