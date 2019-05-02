class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  belongs_to :user
  #we are required to validate that product must belong to a user, cause looks likes belongs_to requires that after rails 5
  has_many :orders, through: :orderitems
  has_many :orderitems

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :description, :photo_url, presence: true
end
