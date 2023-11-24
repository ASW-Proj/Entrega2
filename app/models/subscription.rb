class Subscription < ApplicationRecord
  validates :user, uniqueness: { scope: :community }
  belongs_to :user
  belongs_to :community
end
