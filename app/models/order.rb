class Order < ApplicationRecord
  has_many :orderitems
  has_many :products, through: :orderitems

  validates :status, presence: true, inclusion: {in: %w(pending paid complete cancelled)}

  # we should talk about this and if this is how we want to set up the order process
  # validates :name, :email, :address, :credit_card, :exp, presence: true, on: :update
end
