class CommentsController < ApplicationController


      before_action :authenticate_user, if: -> { %w[post put delete].include?(request.method.downcase) }


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
        if @current_user
          user_id = @current_user
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
        post_title: Post.find(comment.post_id).title,
        community_id: Post.find(comment.post_id).community_id,
        community_name: Community.find(Post.find(comment.post_id).community_id).name,
        community_avatar: Community.find(Post.find(comment.post_id).community_id).community_avatar.attached? ? url_for(Community.find(Post.find(comment.post_id).community_id).community_avatar) : nil,
        user_id: comment.user_id,
        user_name: User.find(comment.user_id).username ,
        user_avatar: User.find(comment.user_id).user_avatar.attached? ? url_for( User.find(comment.user_id).user_avatar) : nil,

        user_saved: (@current_user && SavedComment.find_by(comment_id: comment.id, user_id: @current_user.id).present? )? true : false,
        parent_id: comment.parent_id,
        created_at: comment.created_at,
        updated_at: comment.updated_at,
        num_replies: comment.replies.count,
        likes: {
                         positive: comment.comment_likes.where(positive: true).count || 0,
                         negative: comment.comment_likes.where(positive: false).count || 0,
                         user_like: @current_user ? comment.comment_likes.where(user: @current_user, positive: true).exists? : nil

        }
      }
    end


    render json: { comments: comments_json }, status: :ok
  end


  def self.parent_references_count
      group(:parent_id).count
    end


  # GET /comments/new
  def new
    @comment = Comment.new
  end


#POST /comments
def create
  # Creates an instance of comment
  @comment = Comment.new(comment_params)
  @comment.community_id = Post.find(@comment.post_id).community_id
  if @current_user != nil
    @comment.user_id = @current_user.id
  elsif api_key.nil?
    render :json => { "status" => "401", "error" => "No Api key provided." }, status: :unauthorized and return
  end
  # Save it in DB
  if @comment.save
    render json: {
      message: 'Comment created successfully',
      comment: {
        id: @comment.id,
        body: @comment.body,
        post_id: @comment.post_id,
        user_id: @comment.user_id,
        created_at: @comment.created_at,
        updated_at: @comment.updated_at,
        num_replies: @comment.replies.count,
        likes: {
          positive: @comment.comment_likes.where(positive: true).count || 0,
          negative: @comment.comment_likes.where(positive: false).count || 0
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
    num_replies: @comment.replies.count,
    likes: {
      positive: @comment.comment_likes.where(positive: true).count || 0,
      negative: @comment.comment_likes.where(positive: false).count || 0
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
            positive: reply.comment_likes.where(positive: true).count || 0,
            negative: reply.comment_likes.where(positive: false).count || 0
          }
    }
  end

  render json: { comment: comment_json, replies: replies_json }, status: :ok
end


# DELETE /comments/1
def destroy
  @comment = Comment.find(params[:id])
  if @comment.user_id == @current_user.id
    if @comment.destroy
      render json: { message: 'Comment deleted successfully' }, status: :ok
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  else
    render json: { message: 'This user is not the creator' }, status: :unprocessable_entity

  end

end


# PUT /comments/1
  def update
    @comment = Comment.find(params[:id])
    if @comment.user_id == @current_user.id
      if @comment.update(comment_params)
        render json: {
          message: 'Comment updated successfully',
          comment: {
            id: @comment.id,
            body: @comment.body,
            post_id: @comment.post_id,
            user_id: @comment.user_id,
            created_at: @comment.created_at,
            updated_at: @comment.updated_at,
            num_replies: @comment.replies.count,
            likes: {
              positive: @comment.comment_likes.where(positive: true).count || 0,
              negative: @comment.comment_likes.where(positive: false).count || 0
            }
          }
        }, status: :ok
      else
        render json: {
          errors: @comment.errors.full_messages
        }, status: :unprocessable_entity
      end
  else
    render json: { message: 'This user is not the creator' }, status: :unprocessable_entity
  end
  end



  def likes
    comment.comment_likes.where(positive: true) - comment.comment_likes.where(positive: false)
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

        def comment_params
            params.require(:comment).permit(:body,  :post_id, :parent_id)
        end

end