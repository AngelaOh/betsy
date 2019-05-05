class Order < ApplicationRecord
  has_many :orderitems
  #is the line above needed? or redundant using through
  has_many :products, through: :order_items

  validates :status, presence: true, inclusion: {in: %w(pending paid complete cancelled)}

  # we should talk about this and if this is how we want to set up the order process
  # validates :name, :email, :address, :credit_card, :exp, presence: true, on: :update
end
