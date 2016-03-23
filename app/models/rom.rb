class Rom < ActiveRecord::Base
  validates :title, presence: true
  has_attached_file :frontcover, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  has_attached_file :backcover, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_size :frontcover, :less_than => 5.megabytes
  validates_attachment_size :backcover, :less_than => 5.megabytes
  validates_attachment_content_type :frontcover, :content_type => ['image/jpeg', 'image/png']
  validates_attachment_content_type :backcover, :content_type => ['image/jpeg', 'image/png']
end
