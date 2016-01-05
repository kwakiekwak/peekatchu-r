class AddCategoryToChallenge < ActiveRecord::Migration
  def change
    add_reference :challenges, :category, index: true, foreign_key: true
  end
end
