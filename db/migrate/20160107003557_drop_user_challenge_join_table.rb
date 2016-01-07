class DropUserChallengeJoinTable < ActiveRecord::Migration
  def change
    drop_table :user_challenge_join_tables
  end
end
