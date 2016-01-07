class UsersChallenge < ActiveRecord::Base
  belongs_to :user
  belongs_to :challenge
end
