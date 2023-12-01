class SubscriptionsController < ApplicationController
    before_action :authenticate_user, if: -> { %w[post put delete].include?(request.method.downcase) }
    attr_reader :current_user


    # POST /community/:community_id/subscribe/:user_id
    def subscribe
        @subscription = Subscription.new(community: community, user: user)

        if @subscription.save
            render json: {
                message: 'Subscribed successfully',
                user_id: @subscription.user.id,
                community_id: @subscription.community.id
            }, status: :ok
        else
            render json: {
                errors: @subscription.errors.full_messages
            }, status: :unprocessable_entity
        end
    end

    # DELETE /community/:community_id/unsubscribe/:user_id
    def unsubscribe
        @subscription = community.subscriptions.find_by(user: user)

        if !@subscription.nil?
            @subscription.destroy!
            render json: {
                message: 'Unsubscribed successfully',
            }, status: :ok
        else
            render json: {
                errors: ['The user was not subscribed to the community']
            }, status: :unprocessable_entity
        end
    end

    # Community getter
    def community
        @community ||= Community.find(params[:community_id])
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