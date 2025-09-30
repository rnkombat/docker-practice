class AddLockedToTopics < ActiveRecord::Migration[7.1]
  def change
    add_column :topics, :locked, :boolean, default: false, null: false
  end
end
