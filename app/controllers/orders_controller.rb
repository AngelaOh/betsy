class OrdersController < ApplicationController
  def cart # One cart (@order) holds information on zero or many OrderItems
    @order = Order.new(status: "pending")
    @items = OrderItem.all
  end

  def new_order_item
    # TODO: Quantity should come from product#show view; hardcoded for now
    @item = OrderItem.new(quantity: 1, order_id: @order.id, product_id: params[:id])
  end

  def show # once user clicks checkout from order#cart view, the status should change to the next one. What are our statuses?
    @order.status = "shipping"
    @items.destroy
  end
end
