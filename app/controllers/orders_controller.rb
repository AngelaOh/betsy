class OrdersController < ApplicationController
  before_action :find_session_order, only: [:cart, :new_order_item, :new, :update, :show]

  def cart # One cart (@order) holds information on zero or many OrderItems
    if @order.nil?
      @order = Order.create(status: "pending")
      session[:order_id] = @order.id
    end

    if @order && @order.order_items.length != 0
      @items = OrderItem.where(order_id: @order.id)
    end
  end

  def new_order_item
    if @order.nil?
      @order = Order.create(status: "pending")
      session[:order_id] = @order.id
    else
      @item = OrderItem.create(quantity: 1, order_id: @order.id, product_id: params[:id])
      @order.order_items << @item
      flash[:success] = "#{Product.find_by(id: @item.product_id).name} added to the shopping cart."
      redirect_to product_path(params[:id])
    end
  end

  def new #this should gather info for order's name, email, address, cc, etc...
    if @order.nil? || @order.order_items.length == 0
      flash[:error] = "This order does not exist"
      redirect_to root_path
    end
  end

  def update #this should update order with info above
    if @order.nil? || @order.order_items.length == 0
      flash[:error] = "This order does not exist"
      redirect_to root_path
    end
    
    @order.status = "paid"
    @order.save

    is_successful = @order.update(order_params)
    if is_successful
      flash[:success] = "Order submitted! Check your inbox for confirmation email :D"
      redirect_to order_path(params[:id])
    else
      @order.errors.messages.each do |field, messages|
        flash.now[field] = messages
      end
      render :new, status: :bad_request
    end

    # redirect_to order_path(params[:id])
  end

  def destroy
    @item = OrderItem.find_by(product_id: params[:id])

    if @item.nil?
      flash[:error] = "This item is not currently in your cart."
    else
      @item.destroy
      flash[:success] = "Successfully deleted item from cart."
    end

    redirect_to cart_path
  end

  def show # once user clicks checkout from order#cart view, the status should change to the next one.
    if @order.nil? || @order.order_items.length == 0
      flash[:error] = "This order does not exist"
      redirect_to root_path
    else
      @items = OrderItem.where(order_id: @order.id)
      @order.status = "complete"
      @order.save
      # raise
      @items.each do |item|
        Product.find_by(id: item.product_id).inventory = Product.find_by(id: item.product_id).inventory - item.quantity #change inventory of Products
      end

      OrderItem.where(order_id: @order.id).each do |item|
        item.destroy
      end 
    end
  end

  private

  def order_params
    return params.require(:order).permit(:status, :name, :email, :address, :credit_card, :exp)
  end

  def find_session_order
    if session[:order_id]
      @order = Order.find_by(id: session[:order_id])
    end

    return @order
  end
end
