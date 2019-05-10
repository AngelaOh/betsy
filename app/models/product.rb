class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  #should it be has many categories through that one table?
  belongs_to :user
  #we are required to validate that product must belong to a user, cause looks likes belongs_to requires that after rails 5
  has_many :orders, through: :order_items
  has_many :order_items

  validates :name, presence: true, uniqueness: true
  validates :price, :inventory, presence: true, numericality: {only_integer: true, greater_than: 0}
  validates :description, :photo_url, presence: true
  # validates :categories, presence: true
  # next time when we add categories table
end
