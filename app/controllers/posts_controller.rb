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

    private
        # Only allow a list of trusted parameters through.
        def post_params
            params.require(:post).permit(:title, :url, :body, :user_id, :community_id)
        end
end