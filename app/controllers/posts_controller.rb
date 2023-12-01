class PostsController < ApplicationController

    # POST /posts
    def create
        # Creates an instance of post
        @post = Post.new(post_params)
        # Save it in DB
        if @post.save
            render json: {
                message: 'Post created successfully',
                post: {
                    id: @post.id,
                    title: @post.title,
                    url: @post.url,
                    body: @post.body,
                    creator_id: @post.user.id,
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

        # Buscamos los posts por title
        if params[:search].present?
          value = params[:search]
          @posts = @posts.where('title LIKE ?', "%#{value}%")
        end

        # Filtramos los posts
        if params[:filter].present?
            if params[:user_id].present?
              user_id = params[:user_id]
              subs = params[:filter]
              case subs
              when 'subscribed'
                  @posts = Post.joins(:community, community: :subscriptions)
                                     .where(subscriptions: { user_id: user_id })
                                     .order('posts.created_at DESC')
              when 'created'
                  @posts = Post.where( user_id: user_id )
                                   .order('posts.created_at DESC')
              when 'saved'
                  @posts = Post.joins(:saved_posts)
                                 .where(saved_posts: { user_id: user_id })
                                 .order('posts.created_at DESC')
              end
            else
            #si no hay user id no podemos hacer ninguno de los filtros
              render json: {
                errors: "Mismatch user_id"
              }, status: :unprocessable_entity
              return
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
            @posts = @posts.order('posts.comments.count DESC')
          when 'likes'
            @posts = @posts
              .select('posts.*, COUNT(CASE WHEN post_likes.positive THEN 1 ELSE NULL END) AS positive_likes_count, COUNT(CASE WHEN NOT post_likes.positive THEN 1 ELSE NULL END) AS negative_likes_count')
              .joins('LEFT JOIN post_likes ON post_likes.post_id = posts.id')
              .group('posts.id')
              .order('positive_likes_count DESC, negative_likes_count ASC')

          end
        end

        posts_json = @posts.map do |post|
          {
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


        render json: { posts: posts_json }, status: :ok
      end



      # GET /posts/:id
      def show
        @post = Post.find(params[:id])

        post_json = {
            id: @post.id,
            title: @post.title,
            url: @post.url,
            body: @post.body,
            user_id: @post.user_id,
            community_id: @post.community_id,
            created_at: @post.created_at,
            updated_at: @post.updated_at,
            comments: @post.comments.count,
            likes: {
                             positive: @post.post_likes.where(positive: true).count || 0,
                             negative: @post.post_likes.where(positive: false).count || 0
                           }
          }

        comments_json = @post.comments.map do |comment|
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

        render json: { comment: comment_json, replies: replies_json }, status: :ok
      end



    # DELETE /posts/1
    def destroy
      @post = Post.find(params[:id])

      if @post.destroy
        render json: { message: 'Post deleted successfully' }, status: :ok
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end


    # POST /posts/1/edit
      def update
        @post = Post.find(params[:id])

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
              comments: @post.comments.count,
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
      end




    private
        # Only allow a list of trusted parameters through.
        def post_params
            params.require(:post).permit(:title, :url, :body, :user_id, :community_id)
        end
end