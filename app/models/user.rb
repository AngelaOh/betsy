class User < ApplicationRecord
  has_many :products
  validates :username, :email, presence: true, uniqueness: true

  def self.build_from_github(auth_hash)
    return User.new(uid: auth_hash[:uid], provider: "github",
                    email: auth_hash["info"]["email"],
                    username: auth_hash["info"]["name"])
  end

  def find_order
    merchant_products = Product.where(user_id: id)
    #def self.blah applies to the class
    #inside the method self refers to the object itself
    #we care about the current user, not User class
    orders_array = []
    merchant_products.each do |prod|
      OrderItem.where(product_id: prod.id).each do |order_item|
        orders_array << order_item
      end
    end
    tz = []
    orders_array.each do |poop|
      tz << poop.order
    end
    return tz.uniq
  end
end
