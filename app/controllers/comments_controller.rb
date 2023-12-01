class CommentsController < ApplicationController

  # GET /comments or /comments.json
  def index
    @comments = Comment.all

    # Buscamos los comentarios por body
    if params[:search].present?
      value = params[:search]
      @comments = @comments.where('body LIKE ?', "%#{value}%")
    end

    # Filtramos los comentarios
    if params[:filter].present?
        if params[:user_id].present?
          user_id = params[:user_id]
          subs = params[:filter]
          case subs
          when 'subscribed'
              @comments = Comment.joins(:community, community: :subscriptions)
                                 .where(subscriptions: { user_id: user_id })
                                 .order('comments.created_at DESC')
          when 'created'
              @comments = Comment.where( user_id: user_id )
                               .order('comments.created_at DESC')
          when 'saved'
              @comments = Comment.joins(:saved_comments)
                             .where(saved_comments: { user_id: user_id })
                             .order('comments.created_at DESC')
          end
        else
        #si no hay user id no podemos hacer ninguno de los filtros
          render json: {
            errors: "Mismatch user_id"
          }, status: :unprocessable_entity
          return
        end
    end

    # Ordenamos los comentarios
    if params[:order].present?
      order = params[:order]
      case order
      when 'recent'
        @comments = @comments.order(created_at: :desc)
      when 'oldest'
        @comments = @comments.order(created_at: :asc)
      when 'mostcommented'
        @comments = Comment
          .select('comments.*, COUNT(replies.id) AS replies_count')
          .joins('LEFT JOIN comments AS replies ON replies.parent_id = comments.id')
          .group('comments.id')
          .order('replies_count DESC')
      when 'likes'
        @comments = Comment
          .select('comments.*, COUNT(CASE WHEN comment_likes.positive THEN 1 ELSE NULL END) AS positive_likes_count, COUNT(CASE WHEN NOT comment_likes.positive THEN 1 ELSE NULL END) AS negative_likes_count')
          .joins('LEFT JOIN comment_likes ON comment_likes.comment_id = comments.id')
          .group('comments.id')
          .order('positive_likes_count DESC, negative_likes_count ASC')

      end
    end

    comments_json = @comments.map do |comment|
      {
        id: comment.id,
        body: comment.body,
        post_id: comment.post_id,
        user_id: comment.user_id,
        created_at: comment.created_at,
        updated_at: comment.updated_at,
        replies: comment.replies.count,
        likes: {
          positive: comment.positive_likes_count || 0,
          negative: comment.negative_likes_count || 0
        }
      }
    end


    render json: { comments: comments_json }, status: :ok
  end


  def self.parent_references_count
      group(:parent_id).count
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
           id: comment.id,
           body: comment.body,
           post_id: comment.post_id,
           user_id: comment.user_id,
           created_at: comment.created_at,
           updated_at: comment.updated_at,
           replies: comment.replies.count,
           likes: {
             positive: comment.positive_likes_count || 0,
             negative: comment.negative_likes_count || 0
           }
         }
        }, status: :created
    else
        render json: {
          errors: @comment.errors.full_messages
        }, status: :unprocessable_entity
    end
end



# GET /comments/:id
def show
  @comment = Comment.find(params[:id])

  comment_json = {
    id: @comment.id,
    body: @comment.body,
    post_id: @comment.post_id,
    user_id: @comment.user_id,
    created_at: @comment.created_at,
    updated_at: @comment.updated_at,
    replies: @comment.replies.count,
    likes: {
      positive: @comment.positive_likes_count || 0,
      negative: @comment.negative_likes_count || 0
    }
  }

  replies_json = @comment.replies.map do |reply|
    {
      id: reply.id,
      body: reply.body,
      user_id: reply.user_id,
      created_at: reply.created_at,
      updated_at: reply.updated_at,
      likes: {
        positive: reply.positive_likes_count || 0,
        negative: reply.negative_likes_count || 0
      }
    }
  end

  render json: { comment: comment_json, replies: replies_json }, status: :ok
end














  # Only allow a list of trusted parameters through.
  def comment_params
    #if current_user != nil
     # params.require(:comment).permit(:body, :user_id, :post_id, :parent_id, :community_id)
    #else
      params.require(:comment).permit(:body, :user_id,  :post_id, :parent_id, :community_id)
    #end
  end

  def likes
    comment.comment_likes.where(positive: true) - comment.comment_likes.where(positive: false)
  end

end