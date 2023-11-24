class AddCommunityToComment < ActiveRecord::Migration[7.1]
  def change
    add_reference :comments, :community, null: false, foreign_key: true
  end
end
