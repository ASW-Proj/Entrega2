class CommunitiesController < ApplicationController
    before_action :authenticate_user

    # GET /communities
    def index
        # If a query param called user_id is present, obtain the communities
        # where the user with that user_id is subscribed (filter)
        if params[:user_id].present?
            user_id = params[:user_id]
            @communities = Community
                             .joins(:subscriptions)
                             .where(subscriptions: { user_id: user_id })
                             .order(name: :asc)
        # Else get communities ordered by name
        else
            @communities = Community.all.order(name: :asc)
        end

        # The json to add to the response
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

        # The response
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
    def authenticate_user
        token = extract_token_from_request
    
        unless token_valid?(token)
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      end
    
      def extract_token_from_request
        # Extraer el token Bearer del encabezado Authorization
        header = request.headers['Authorization']
        header&.split(' ')&.last # Tomar la parte del token después de 'Bearer'
      end
    
      def token_valid?(token)
        # Aquí debes validar si el token es válido
        # Esto podría incluir la verificación del token JWT, por ejemplo
        # Aquí asumimos una simple verificación si el token no está en blanco
        !token.nil? && !token.empty?
      end
        # Only allow a list of trusted parameters through.
        def community_params
            params.require(:community).permit(:identifier, :name, :community_avatar, :community_banner)
        end
end