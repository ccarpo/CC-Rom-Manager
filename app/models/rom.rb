class Rom < ActiveRecord::Base
  validates :title, presence: true
  has_many :genres, dependent: :destroy 
end
