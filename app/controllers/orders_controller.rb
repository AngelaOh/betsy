class OrdersController < ApplicationController
  def cart
    @order = Order.new(status: "pending")
    @items = OrderItem.all
  end

  def show
  end

  def new_order_item
    # TODO: Quantity should come from product show view; hardcoded now
    @item = OrderItem.new(quantity: 1, order_id: @order.id, product_id: params[:id])
  end
end
