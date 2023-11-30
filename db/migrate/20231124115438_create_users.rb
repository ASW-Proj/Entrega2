class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :name
      t.text :bio
<<<<<<< HEAD
=======
      t.text :email, null: false
>>>>>>> main

      t.timestamps
    end
  end
end
