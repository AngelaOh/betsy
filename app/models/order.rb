class Order < ApplicationRecord
  has_many :order_items
  has_many :products, through: :order_items

  validates :status, presence: true, inclusion: { in: %w(pending paid complete cancelled) }

  validates :name, :email, :address, :credit_card, :exp, presence: true, on: :update
  validates :credit_card, numericality: { only_integer: true }, on: :update

  def ordertotalprice
    total = 0
    self.order_items.each do |item|
      total += item.orderitemprice
    end
    return total
  end
end
