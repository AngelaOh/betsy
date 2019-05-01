class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  belongs_to :user
  has_many :orders, through: :orderitems
  has_many :orderitems
end
