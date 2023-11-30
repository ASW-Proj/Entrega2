class CommentsController < ApplicationController

  # GET /comments or /comments.json
  def index

    order_param = params[:order]
    case order_param
        when 'recent'
          @comments = Comment.all.order(created_at: :desc)
        when 'oldest'
          @comments = Comment.all.order(created_at: :asc)
        end
    post = params[:post]
    user = params[:user]
    if post != nil and user = nil
      if post.where(id: post).exists?
        @comments =@comments.where(post_id: post)
      else
        render :json => { "status" => "404", "error" => "This post does not exist." }, status: :not_found and return
      end
    elsif user != nil
      if User.where(id: user).exists?
        @comments = @comments.where(user_id: user)
      else
        render :json => { "status" => "404", "error" => "This user does not exist." }, status: :not_found and return
      end
    end
  comments_json = @comments.map do |comment|
              {
                body: comment.body,
                post_id: comment.post_id,
                user_id: comment.user_id,
                created_at: comment.created_at,
                updated_at: comment.updated_at,

              }
  end
  render json: { comments: comments_json }, status: :ok
  end





  # GET /comments/1 or /comments/1.json
  def show
    @comment = Comment.find(params[:id])
  end


  # GET /comments/new
  def new
    @comment = Comment.new
  end


#POST /comments
def create
     # Creates an instance of comment

    @comment = Comment.new(comment_params)

    # Save it in DB
    if @comment.save
        render json: {
          message: 'Comment created successfully',
          comment: {
            body:@comment.body,
            user_id: @comment.user_id,
            post_id: @comment.post_id,
            created_at: @comment.created_at,
            updated_at: @comment.updated_at
          }
        }, status: :created
    else
        render json: {
          errors: @comment.errors.full_messages
        }, status: :unprocessable_entity
    end
end









  # Only allow a list of trusted parameters through.
  def comment_params
    #if current_user != nil
     # params.require(:comment).permit(:body, :user_id, :post_id, :parent_id, :community_id)
    #else
      params.require(:comment).permit(:body, :user_id,  :post_id, :parent_id, :community_id)
    #end
  end

end