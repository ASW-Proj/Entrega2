class Post < ApplicationRecord
  belongs_to :community
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :post_likes, dependent: :destroy
  has_many :saved_posts, dependent: :destroy

  validates :title, presence: true, :length => {
    :minimum => 4,
    :maximum => 255,
    :too_short => "must have at least %{count} characters",
    :too_long  => "must have at most %{count} characters",
  }
  validates :url, url: true
end
