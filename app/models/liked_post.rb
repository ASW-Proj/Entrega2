class LikedPost < ApplicationRecord
  belongs_to :user
  belongs_to :post
end
