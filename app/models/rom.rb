class Rom < ActiveRecord::Base
  validates :title, presence: true
end
