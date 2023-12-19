class PostsController < ApplicationController

      before_action :authenticate_user, if: -> { %w[post put delete].include?(request.method.downcase) }

    # POST /posts
    def create
        # Creates an instance of post
        @post = Post.new(post_params)

        if @current_user != nil
          @post.user_id = @current_user.id
        elsif api_key.nil?
          render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
        end
        # Save it in DB
          if @post.save
              render json: {
                  message: 'Post created successfully',
                  post: {
                      id: @post.id,
                      title: @post.title,
                      url: @post.url,
                      body: @post.body,
                      creator_id: @post.user_id,
                      community_id: @post.community.id,
                      created_at: @post.created_at,
                      updated_at: @post.updated_at
                  }
              }, status: :created
          else
              render json: {
                  errors: @post.errors.full_messages
              }, status: :unprocessable_entity
              end

    end

    # GET /posts or /posts.json
    def index
        @posts = Post.all
        authenticate_user2

        # Buscamos los posts por title
        if params[:search].present?
            value = params[:search]
            @posts = @posts.where('title LIKE ?', "%#{value}%")
        end

        # Filtramos los posts
        if params[:filter].present?
                subs = params[:filter]
                case subs
                    when 'subscribed'
                        @posts = Post.joins(:community, community: :subscriptions)
                                     .where(subscriptions: { user_id: @current_user.id})
                                     .order('posts.created_at DESC')
                    when 'created'
                        @posts = Post.where( user_id: @current_user )
                                     .order('posts.created_at DESC')
                    when 'saved'
                        @posts = Post.joins(:saved_posts)
                                     .where(saved_posts: { user_id: @current_user.id })
                                     .order('posts.created_at DESC')
                end
        end

        # Ordenamos los posts
        if params[:order].present?

      
          order = params[:order]
          case order
          when 'recent'
            @posts = @posts.order(created_at: :desc)
          when 'oldest'
            @posts = @posts.order(created_at: :asc)
          when 'mostcommented'
            @posts = @posts
              .joins(:comments)
              .group('posts.id') # Ensure each post is only counted once
              .order('COUNT(comments.id) DESC')

          when 'likes'
            @posts = @posts
              .select('posts.*, COUNT(CASE WHEN post_likes.positive THEN 1 ELSE NULL END) AS positive_likes_count, COUNT(CASE WHEN NOT post_likes.positive THEN 1 ELSE NULL END) AS negative_likes_count')
              .joins('LEFT JOIN post_likes ON post_likes.post_id = posts.id')
              .group('posts.id')
              .order('positive_likes_count DESC, negative_likes_count ASC')

          end

        end

        posts_json = @posts.map do |post| {
            id: post.id,
            title: post.title,
            url: post.url,
            body: post.body,
            user_id: post.user_id,
            user_name: User.find(post.user_id).username ,
            user_avatar: User.find(post.user_id).user_avatar.attached? ? url_for( User.find(post.user_id).user_avatar) : nil,
            user_saved: SavedPost.find_by(post_id: post.id, user_id: @current_user.id).present? ? true : false,
            community_id: post.community_id,
            community_name: Community.find(post.community_id).name,
            community_avatar: Community.find(post.community_id).community_avatar.attached? ? url_for( Community.find(post.community_id).community_avatar) : nil,
            created_at: post.created_at,
            updated_at: post.updated_at,
            num_comments: post.comments.count,
            likes: {
                positive: post.post_likes.where(positive: true).count || 0,
                negative: post.post_likes.where(positive: false).count || 0,
                user_like: @current_user ? post.post_likes.where(user: @current_user, positive: true).exists? : nil
            }


        }
        end

        render json: { posts: posts_json }, status: :ok
    end



      # GET /posts/1
    def show
        @post = Post.find(params[:id])

        comments_json = @post.comments.map do |comment| {
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

        post_json = {
            id: @post.id,
            title: @post.title,
            url: @post.url,
            body: @post.body,
            user_id: @post.user_id,
            community_id: @post.community_id,
            created_at: @post.created_at,
            updated_at: @post.updated_at,
            comments: comments_json,
            likes: {
                positive: @post.post_likes.where(positive: true).count || 0,
                negative: @post.post_likes.where(positive: false).count || 0
            }
        }

        render json: { post: post_json }, status: :ok
    end



    # DELETE /posts/1
    def destroy
      @post = Post.find(params[:id])
      if @post.user_id == @current_user.id
        if @post.destroy
          render json: { message: 'Post deleted successfully' }, status: :ok
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { message: 'This user is not the creator' }, status: :unprocessable_entity
      end
    end


    # PUT /posts/1
    def update
        @post = Post.find(params[:id])
        if @post.user_id == @current_user.id
          if @post.update(post_params)
            render json: {
                message: 'Post updated successfully',
                post: {
                    id: @post.id,
                    title: @post.title,
                    url: @post.url,
                    body: @post.body,
                    user_id: @post.user_id,
                    community_id: @post.community_id,
                    created_at: @post.created_at,
                    updated_at: @post.updated_at,
                    num_comments: @post.comments.count,
                    likes: {
                        positive: @post.post_likes.where(positive: true).count || 0,
                        negative: @post.post_likes.where(positive: false).count || 0
                    }
                }
            }, status: :ok
          else
              render json: {
              errors: @post.errors.full_messages
              }, status: :unprocessable_entity
          end
        else
          render json: { message: 'This user is not the creator' }, status: :unprocessable_entity
        end
    end



    private
        # Only allow a list of trusted parameters through.
        def post_params
            params.require(:post).permit(:title, :url, :body, :community_id)
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
        def authenticate_user2
          token = extract_token_from_request
          if token_valid?(token)
            @current_user = User.find_by(api_key: token)
          end
        end

end