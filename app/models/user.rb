class User < ApplicationRecord
  has_many :products
  validates :username, :email, presence: true, uniqueness: true

  def self.build_from_github(auth_hash)
    return User.new(uid: auth_hash[:uid], provider: "github",
                    email: auth_hash["info"]["email"],
                    username: auth_hash["info"]["nickname"])
  end

  def findorder
    all_user_products = Product.where(user_id: id)
    all_user_orders = []
    all_user_products.each do |prod|
      OrderItem.where(product_id: prod.id).each do |orderitem|
        all_user_orders << orderitem.order
      end
    end
    return all_user_orders.uniq
  end

  def totalrev
    totalorders = findorder
    totalrev = 0
    totalorders.each do |order|
      order.order_items.each do |orderitem|
        if orderitem.product.user_id == id && order.status != "pending" && order.status != "cancelled"
          totalrev += orderitem.orderitemprice
        end
      end
    end
    return totalrev
  end

  def totalrevstatus
    totalorders = findorder
    totalrev = 0
    hashy = {
      "pending" => 0,
      "paid" => 0,
      "complete" => 0,
      "cancelled" => 0,
    }
    totalorders.each do |order|
      order.order_items.each do |orderitem|
        if orderitem.product.user_id == id && order.status == "pending"
          # binding.pry
          hashy["pending"] += orderitem.orderitemprice
        elsif orderitem.product.user_id == id && order.status == "paid"
          hashy["paid"] += orderitem.orderitemprice
        elsif orderitem.product.user_id == id && order.status == "complete"
          hashy["complete"] += orderitem.orderitemprice
        elsif orderitem.product.user_id == id && order.status == "cancelled"
          hashy["cancelled"] += orderitem.orderitemprice
        end
      end
    end
    return hashy
  end

  def ordercount
    hashy = {
      "pending" => 0,
      "paid" => 0,
      "complete" => 0,
      "cancelled" => 0,
    }
    totalorders = findorder
    totalorders.each do |order|
      if order.status == "pending"
        hashy["pending"] += 1
      elsif order.status == "paid"
        hashy["paid"] += 1
      elsif order.status == "complete"
        hashy["complete"] += 1
      elsif order.status == "cancelled"
        hashy["cancelled"] += 1
      end
    end
    return hashy
  end
end
