class AddCommunityToPost < ActiveRecord::Migration[7.1]
  def change
    add_reference :posts, :community, null: false, foreign_key: true
  end
end
