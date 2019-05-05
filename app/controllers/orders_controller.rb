class OrdersController < ApplicationController
  def cart # One cart (@order) holds information on zero or many OrderItems
    @order = Order.find_by(status: "pending") # under the assumption there is only one order happening at a time, does this logic work?
    if @order && @order.order_items.length != 0
      @items = OrderItem.where(order_id: @order.id)
    end
  end

  def new_order_item
    # TODO: Quantity should come from product#show view; hardcoded for now
    if Order.find_by(status: "pending")
      @order = Order.find_by(status: "pending")
    else
      @order = Order.create(status: "pending")
    end

    @item = OrderItem.create(quantity: 1, order_id: @order.id, product_id: params[:id])
    @order.order_items << @item
    redirect_to product_path(params[:id])
  end

  def new #this should gather info for order's name, email, address, cc, etc...
    @order = Order.find_by(status: "pending")
  end

  def update #this should update order with info above
    @order = Order.find_by(status: "pending")
    @order.status = "paid"
    @order.save

    is_successful = @order.update(order_params)
    if is_successful
      flash[:success] = "TESTTEST: order has been updated."
    else
      @order.errors.messages.each do |field, messages|
        flash.now[field] = messages
      end
      render :new, status: :bad_request
    end

    redirect_to order_path(params[:id])
  end

  def show # once user clicks checkout from order#cart view, the status should change to the next one.
    @order = Order.find_by(status: "paid")
    @items = OrderItem.where(order_id: @order.id)
    @order.status = "shipped"
    @items.each do |item|
      Product.find_by(id: item.product_id).inventory = Product.find_by(id: item.product_id).inventory - item.quantity #change inventory of Products
    end
  end

  private

  def order_params
    return params.require(:order).permit(:status, :name, :email, :address, :credit_card, :exp)
  end
end
