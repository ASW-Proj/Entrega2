class CommentLikesController < ApplicationController

      before_action :authenticate_user, if: -> { %w[post put delete].include?(request.method.downcase) }

    # POST /comment/:comment_id/like/:user_id
    def like
        if comment.comment_likes.find_by(user: @current_user).nil?
            @liked_comment = CommentLike.new(comment: comment, user: @current_user, positive: positive)

            if @liked_comment.save
                render json: {
                    message: 'Liked successfully',
                    positive: @liked_comment.positive,
                    user_id: @liked_comment.user.id,
                    comment_id: @liked_comment.comment.id
                }, status: :ok
            else
                render json: {
                    errors: @liked_comment.errors.full_messages
                }, status: :unprocessable_entity
            end
        else
            @liked_comment = comment.comment_likes.find_by(user: @current_user)

            if @liked_comment.update(positive: positive)
                render json: {
                    message: 'Like updated successfully',
                    positive: @liked_comment.positive,
                    user_id: @liked_comment.user.id,
                    comment_id: @liked_comment.comment.id
                }, status: :ok
            else
                render json: {
                    errors: @liked_comment.errors.full_messages
                }, status: :unprocessable_entity
            end
        end
    end

    # DELETE /comment/:comment_id/like/:user_id
    def unlike
        @liked_comment = comment.comment_likes.find_by(user: @current_user)

        if !@liked_comment.nil?
            @liked_comment.destroy!
            render json: {
                message: 'The comment is no longer liked',
            }, status: :ok
        else
            render json: {
                errors: ['The comment was not liked']
            }, status: :unprocessable_entity
        end
    end

    # Comment getter
    def comment
        @comment ||= Comment.find(params[:comment_id])
    end

    # User getter
    def user
        @user ||= User.find(params[:user_id])
    end

    private
    def positive
        params.require(:positive)
    end

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