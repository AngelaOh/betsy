class OrdersController < ApplicationController
  def cart # One cart (@order) holds information on zero or many OrderItems
    @order = Order.find_by(status: "pending") # under the assumption there is only one order happening at a time, does this logic work?
    @items = OrderItem.where(order_id: @order.id)
  end

  def new_order_item
    # TODO: Quantity should come from product#show view; hardcoded for now
    @order = Order.create(status: "pending")
    @item = OrderItem.create(quantity: 1, order_id: @order.id, product_id: params[:id])
    @order.order_items << @item
    redirect_to product_path(params[:id])
  end

  def new #this should gather info for order's name, email, address, cc, etc...
  end

  def update #this should update order with info above
  end

  def show # once user clicks checkout from order#cart view, the status should change to the next one. What are our statuses?
    @order.status = "paid"
    Products.find_by(@item.product_id).inventory = Products.find_by(@item.product_id).inventory - @items.quantity #change inventory of Products
    @items.destroy # I want to destroy associated OrderItems
    @order.destroy
  end
end
