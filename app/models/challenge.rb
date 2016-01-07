class Challenge < ActiveRecord::Base
  # changed it from belongs_to
  has_many :users_challenges
  has_many :users, through: :users_challenges
  belongs_to :category
  has_many :posts

  ratyrate_rateable 'challenge_rating'

  validates :title,  presence: true, length: { maximum: 50 }
end
