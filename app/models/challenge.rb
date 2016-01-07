class Challenge < ActiveRecord::Base
  # changed it from belongs_to
  has_and_belongs_to_many :user
  belongs_to :category
  has_many :posts

  validates :title,  presence: true, length: { maximum: 50 }
end
