class CreateCommunities < ActiveRecord::Migration[7.1]
  def change
    create_table :communities do |t|
      t.text :identifier, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
