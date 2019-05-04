class OrdersController < ApplicationController
  def show
  end

  def cart
    @orderitems = OrderItem.all
  end

  def new_item
  end
end
