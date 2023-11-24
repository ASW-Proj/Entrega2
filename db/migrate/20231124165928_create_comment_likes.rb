class CreateCommentLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :comment_likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.boolean :positive, null: false

      t.timestamps
    end

    add_index :comment_likes, [:user_id, :comment_id], unique: true
  end
end