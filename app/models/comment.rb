class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :community
  belongs_to :parent, class_name: 'Comment', optional: true

  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy
  has_many :comment_likes, dependent: :destroy
  has_many :saved_comments, dependent: :destroy

  validates :body, presence: true, :length => {
    :minimum => 4,
    :maximum => 255,
    :too_short => "must have at least %{count} characters",
    :too_long  => "must have at most %{count} characters",
  }
end
