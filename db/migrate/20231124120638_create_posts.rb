class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :url
      t.text :body
      t.integer :points

      t.timestamps
    end
  end
end
