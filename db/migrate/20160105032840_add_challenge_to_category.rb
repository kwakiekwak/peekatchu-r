class AddChallengeToCategory < ActiveRecord::Migration
  def change
    add_reference :categories, :challenge, index: true, foreign_key: true
  end
end
