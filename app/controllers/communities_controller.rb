class CommunitiesController < ApplicationController

    # GET /communities.json
    def index
        @communities = Community.all.order(name: :asc)
    end
    
    # POST /communities.json
    def create
        # Creates an instance of community
        @communtity = Community.new(community_params)

        respond_to do |format|
            # Save it in DB
            if @community.save
                format.json { render json: { message: 'Community created successfully', community: @community }, status: :created }
            else
                format.json { render json: { errors: @community.errors.full_messages }, status: :unprocessable_entity }
            end
        end
    end

    private
        # Only allow a list of trusted parameters through.
        def community_params
            params.require(:community).permit(:identifier, :name, :avatar, :banner)
        end
end