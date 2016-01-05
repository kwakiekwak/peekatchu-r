class Challenge < ActiveRecord::Base
  belongs_to :user
  belongs_to :category

  validates :title,  presence: true, length: { maximum: 50 }
end
