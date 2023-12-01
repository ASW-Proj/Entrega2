class SubscriptionsController < ApplicationController
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
end