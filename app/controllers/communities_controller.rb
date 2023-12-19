class CommunitiesController < ApplicationController
    before_action :authenticate_user, if: -> { %w[post put delete].include?(request.method.downcase) }

    # GET /communities
    def index
        # If a query param called user_id is present, obtain the communities
        # where the user with that user_id is subscribed (filter)
        authenticate_user2
        if @current_user
            user_id = @current_user
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
                    subscribed: @current_user.present? ,#&& community.subscriptions.where(user: @current_user).exists?,
                    created_at: community.created_at,
                    updated_at: community.updated_at,
                }
                end

        # The response
        render json: { communities: communities_json }, status: :ok
    end

    # GET /communities/id
    def show
        @community= Community.find(params[:id])
        if !@community.nil?
            render json: {
                message: 'Community info',
                community: {
                    id: @community.id,
                    identifier: @community.identifier,
                    name: @community.name,
                    community_avatar: @community.community_avatar.attached? ? url_for(@community.community_avatar) : nil,
                    community_banner: @community.community_banner.attached? ? url_for(@community.community_banner) : nil,
                    num_posts: @community.posts.count,
                    num_comments: @community.comments.count,
                    num_subscribers: @community.subscriptions.count,
                    created_at: @community.created_at,
                    updated_at: @community.updated_at,
                }
            }, status: :ok
            if params[:content].present?
                content = params[:content]
                case content
                    when 'posts'
                    posts_json = @community.posts.map do |post|
                        post_json = {
                            id: post.id,
                            title: post.title,
                            url: post.url,
                            body: post.body,
                            user_id: post.user_id,
                            community_id: post.community_id,
                            created_at: post.created_at,
                            updated_at: post.updated_at,
                            comments: post.comments.count,
                            likes: {
                            positive: post.post_likes.where(positive: true).count || 0,
                            negative: post.post_likes.where(positive: false).count || 0
                            }
                        }
                    end
                    when 'comments'
                    comments_json = @community.comments.map do |comment|
                        comment_json = {
                            id: comment.id,
                            body: comment.body,
                            post_id: comment.post_id,
                            user_id: comment.user_id,
                            created_at: comment.created_at,
                            updated_at: comment.updated_at,
                            replies: comment.replies.count,
                            likes: {
                            positive: comment.comment_likes.where(positive: true).count || 0,
                            negative: comment.comment_likes.where(positive: false).count || 0
                            }
                        }
                    end
                else
                end
            else
            end
        else
            render json: {
                errors: @community.errors.full_messages
            }, status: :not_found
        end
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


    # PUT /communities/:id
      def update
        @community = Community.find(params[:id])

        if @community.update(community_params)
          render json: {
            message: 'Community updated successfully',
            community: {
                id: @community.id,
                identifier: @community.identifier,
                name: @community.name,
                created_at: @community.created_at,
                updated_at: @community.updated_at
            }
          }, status: :ok
        else
          render json: {
            errors: @community.errors.full_messages
          }, status: :unprocessable_entity
        end
      end
      
     # DELETE /communities/1
        def destroy
          @community = Community.find(params[:id])

        if @community.destroy
            render json: { message: 'Community deleted successfully' }, status: :ok
        else
            render json: { errors: @community.errors.full_messages }, status: :unprocessable_entity
        end
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

    def authenticate_user2
        token = extract_token_from_request
        if token_valid?(token)
            @current_user = User.find_by(api_key: token)
        end
    end

    def extract_token_from_request
        header = request.headers['Authorization']
        header&.split(' ')&.last
    end

    def token_valid?(token)
        !token.nil? && !token.empty? && User.exists?(api_key: token)
    end

        # Only allow a list of trusted parameters through.
        def community_params
            params.require(:community).permit(:identifier, :name, :community_avatar, :community_banner)
        end



end