class CommentLike < ApplicationRecord
  validates :user, uniqueness: { scope: :comment }
  belongs_to :user
  belongs_to :comment
end
