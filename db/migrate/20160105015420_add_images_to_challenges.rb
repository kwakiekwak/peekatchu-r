class AddImagesToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :images, :string
  end
end
