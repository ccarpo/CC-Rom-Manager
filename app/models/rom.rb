class Rom < ActiveRecord::Base
  validates :title, presence: true
  #attr_accessible :title, :description, :rating, :players, :coop, :releasedate, :developer, :publisher
  has_attached_file :frontcover, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_size :frontcover, :less_than => 5.megabytes
  validates_attachment_content_type :frontcover, :content_type => ['image/jpeg', 'image/png']
end
