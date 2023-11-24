class Community < ApplicationRecord
    has_one_attached :community_avatar
    has_one_attached :community_banner

    has_many :posts, dependent: :restrict_with_exception
    has_many :comments, dependent: :restrict_with_exception
    has_many :subscriptions, dependent: :destroy

    validates :identifier, presence: true, uniqueness: true, :length => {
        :minimum => 1,
        :too_short => "must have at least %{count} characters",
    }

    validates :name, presence: false, uniqueness: true, allow_blank: true, :length => {
        :minimum => 1,
        :maximum => 40,
        :too_short => "must have at least %{count} characters",
        :too_long  => "must have at most %{count} characters",
    }
end
