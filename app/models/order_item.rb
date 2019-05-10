class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order

  validates :order_id, uniqueness: { scope: :product_id }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :order_id, uniqueness: { scope: :product_id }

  def orderitemprice
    return (self.quantity * self.product.price)
  end
end
