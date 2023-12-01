class SavedCommentsController < ApplicationController


          before_action :authenticate_user, if: -> { %w[post put delete].include?(request.method.downcase) }
    attr_reader :current_user

    # POST /comment/:comment_id/save/:user_id
    def save
        @saved_comment = SavedComment.new(comment: comment, user: user)

        if @saved_comment.save
            render json: {
                message: 'Saved successfully',
                user_id: @saved_comment.user.id,
                comment_id: @saved_comment.comment.id
            }, status: :ok
        else
            render json: {
                errors: @saved_comment.errors.full_messages
            }, status: :unprocessable_entity
        end
    end

    # DELETE /comment/:comment_id/save/:user_id
    def unsave
        @saved_comment = comment.saved_comments.find_by(user: user)

        if !@saved_comment.nil?
            @saved_comment.destroy!
            render json: {
                message: 'The comment is no longer saved',
            }, status: :ok
        else
            render json: {
                errors: ['The comment was not saved']
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