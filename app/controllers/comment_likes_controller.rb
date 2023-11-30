class CommentLikesController < ApplicationController
    # POST /comment/:comment_id/like/:user_id
    def like
        if comment.comment_likes.find_by(user: user).nil?
            @liked_comment = CommentLike.new(comment: comment, user: user, positive: positive)

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
            @liked_comment = comment.comment_likes.find_by(user: user)

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
        @liked_comment = comment.comment_likes.find_by(user: user)

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
end