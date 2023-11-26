class CommunitiesController < ApplicationController

    # GET /communities.json
    def index
        @communities = Community.all.order(name: :asc)
    end
    
    # POST /communities.json
    def create
        # Creates an instance of community
        @community = Community.new(community_params)

        # Save it in DB
        if @community.save
            render json: { message: 'Community created successfully', community: @community }, status: :created
        else
            render json: { errors: @community.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private
        # Only allow a list of trusted parameters through.
        def community_params
            params.require(:community).permit(:identifier, :name, :avatar, :banner)
        end
end