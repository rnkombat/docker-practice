class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.references :topic, null: false, foreign_key: true
      t.string :content

      t.timestamps
    end
  end
end
