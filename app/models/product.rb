class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  belongs_to :user
  has_many :orders, through: :order_items
  has_many :order_items

  validates :name, presence: true, uniqueness: true
  validates :price, :inventory, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :description, :photo_url, presence: true
end
