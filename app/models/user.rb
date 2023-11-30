class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

    has_one_attached :user_avatar
    has_one_attached :user_banner

    has_many :comments, dependent: :destroy
    has_many :posts, dependent: :destroy
    has_many :comment_likes, dependent: :destroy
    has_many :post_likes, dependent: :destroy
    has_many :saved_posts, dependent: :destroy
    has_many :saved_comments, dependent: :destroy
end
