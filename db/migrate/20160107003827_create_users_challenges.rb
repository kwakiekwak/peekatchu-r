class CreateUsersChallenges < ActiveRecord::Migration
  def change
    create_table :users_challenges do |t|
      t.references :user, index: true, foreign_key: true
      t.references :challenge, index: true, foreign_key: true
      t.boolean :completed

      t.timestamps null: false
    end
  end
end
