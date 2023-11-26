class CommunitiesController < ApplicationController

    # GET /communities
    def index
        @communities = Community.all.order(name: :asc)

        communities_json = @communities.map do |community|
            {
              id: community.id,
              identifier: community.identifier,
              name: community.name,
              community_avatar: community.community_avatar.attached? ? url_for(community.community_avatar) : nil,
              num_posts: community.posts.count,
              num_comments: community.comments.count,
              num_subscribers: community.subscriptions.count,
              created_at: community.created_at,
              updated_at: community.updated_at,
            }
        end

        render json: { communities: communities_json }, status: :ok
    end


    
    # POST /communities
    def create
        # Creates an instance of community
        @community = Community.new(community_params)

        # Save it in DB
        if @community.save
            render json: {
              message: 'Community created successfully',
              community: {
                id: @community.id,
                identifier: @community.identifier,
                name: @community.name,
                created_at: @community.created_at,
                updated_at: @community.updated_at
              }
            }, status: :created
        else
            render json: {
              errors: @community.errors.full_messages
            }, status: :unprocessable_entity
        end
    end

    private
        # Only allow a list of trusted parameters through.
        def community_params
            params.require(:community).permit(:identifier, :name, :community_avatar, :community_banner)
        end
end