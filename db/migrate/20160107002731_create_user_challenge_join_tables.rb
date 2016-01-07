class CreateUserChallengeJoinTables < ActiveRecord::Migration
  def change
    create_table :user_challenge_join_tables do |t|
      t.references :user, index: true, foreign_key: true
      t.references :challenge, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
