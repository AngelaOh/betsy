class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order

  #maybe add a unique combindation requirement of order id and product id
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :order_id, uniqueness: { scope: :product_id }
end
