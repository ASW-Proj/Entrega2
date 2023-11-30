class CommentsController < ApplicationController

  # GET /comments or /comments.json
  def index
    @comments = Comment.all

    if params[:subscribe].present?
      subs = params[:subscribe]
      case subs
      when 'subscribed'
        @comments = @comments.order(created_at: :desc)
      else
        @comments = @comments.order(created_at: :asc)
      end
    end
    if params[:order].present?
      order = params[:order]
      case order
      when 'recent'
        @comments = @comments.order(created_at: :desc)
      when 'oldest'
        @comments = @comments.order(created_at: :asc)
      end
    end
    if params[:search].present?
      value = params[:search]
      @comments = @comments.where('body LIKE ?', "%#{value}%")
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