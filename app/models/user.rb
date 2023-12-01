class User < ApplicationRecord
    before_create :set_api_key
    has_one_attached :user_avatar
    has_one_attached :user_banner

    has_many :comments, dependent: :destroy
    has_many :posts, dependent: :destroy
    has_many :comment_likes, dependent: :destroy
    has_many :post_likes, dependent: :destroy
    has_many :saved_posts, dependent: :destroy
    has_many :saved_comments, dependent: :destroy

    validates :email, presence: true, :length => {
        :minimum => 5,
        :maximum => 255,
        :too_short => "is not valid",
        :too_long  => "is not valid",
    }
    def generate_api_key
        Digest::MD5.hexdigest(SecureRandom.hex)
    end
    
    def set_api_key
        self.api_key = generate_api_key
    end

end
