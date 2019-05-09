class OrdersController < ApplicationController
  before_action :find_session_order, only: [:cart, :new_order_item, :new, :update, :show]

  def cart # One cart (@order) holds information on zero or many OrderItems
    if @order.nil?
      @order = Order.create(status: "pending")
      session[:order_id] = @order.id
    end

    if @order && @order.order_items.length != 0
      @items = OrderItem.where(order_id: @order.id)

      @items.each do |item|
        if item.product.retired
          item.destroy
        end
      end
    end

    # expires_now if @order
  end

  def new_order_item
    if @order.nil?
      @order = Order.create(status: "pending")
      session[:order_id] = @order.id
    end

    @item = OrderItem.find_by(order_id: @order.id, product_id: params[:id])

    if !@item.nil? # if this item is already in the shopping cart
      if params[:quantity].to_i > Product.find_by(id: @item.product_id).inventory # accounts for trying to buy more than available
        flash[:error] = "We don't have enough items in inventory to fulfill this order."
        redirect_to product_path(params[:id])
        return
      end
      @item.update(quantity: @item.quantity + params[:quantity].to_i) # updates quantity of items in cart
      Product.find_by(id: @item.product_id).update(inventory: Product.find_by(id: @item.product_id).inventory - params[:quantity].to_i)  #change inventory of Products
    else
      @item = OrderItem.create(quantity: params[:quantity], order_id: @order.id, product_id: params[:id])
      # raise
      if params[:quantity].to_i > Product.find_by(id: @item.product_id).inventory
        flash[:error] = "We don't have enough items in inventory to fulfill this order."
        redirect_to product_path(params[:id])
        return
      end
      @order.order_items << @item
      #raise
      Product.find_by(id: @item.product_id).update(inventory: Product.find_by(id: @item.product_id).inventory - @item.quantity)  #change inventory of Products
    end
    flash[:success] = "#{Product.find_by(id: @item.product_id).name} added to the shopping cart."
    # raise
    redirect_to product_path(params[:id])
  end

  def update_order_item_quantity
    # raise
    @order = find_session_order
    @update_item = OrderItem.find_by(order_id: @order.id, product_id: params[:id].to_i)
    updated_inventory = (Product.find_by(id: @update_item.product_id)).inventory - (params[:order_item][:quantity].to_i - @update_item.quantity)
    if updated_inventory <= 0
      flash[:error] = "We don't have enough items in inventory to fulfill this order."
      redirect_to cart_path
      return
    end
    Product.find_by(id: @update_item.product_id).update(inventory: updated_inventory)
    # raise
    @update_item.update(quantity: params[:order_item][:quantity].to_i)
    # raise
    redirect_to cart_path
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
      return
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
    # raise

    if @item.nil?
      flash[:error] = "This item is not currently in your cart."
    else
      Product.find_by(id: @item.product_id).update(inventory: Product.find_by(id: @item.product_id).inventory + @item.quantity)  #change inventory of Products
      # raise
      @item.destroy
      flash[:success] = "Successfully deleted item from cart."
    end

    redirect_to cart_path
  end

  def show # once user clicks checkout from order#cart view, the status should change to the next one.
    @order = Order.find_by(id: params[:id].to_i)
    if @order.nil? || @order.order_items.length == 0
      flash[:error] = "This order does not exist"
      redirect_to root_path
    else
      @items = OrderItem.where(order_id: @order.id)

      session[:order_id] = nil
    end
  end

  def ship_order
    @order = Order.find_by(id: params[:id])
    if @order == nil
      flash[:error] = "This order does not exist"
    else
      if @order.status == "paid"
        @order.update(status: "complete")
        flash[:success] = "You have shipped Order #{@order.id}'s items."
      elsif @order.status == "pending"
        flash[:error] = "This order is not ready to be shipped."
      elsif @order.status == "cancelled"
        flash[:error] = "This order has been cancelled and cannot be shipped."
      else
        flash[:error] = "You have already shipped items in this order."
      end
    end
    redirect_back fallback_location: root_path
  end

  # def cancel_order
  #   @order = Order.find_by(id: params[:id])

  #   if @order.status != "complete"
  #     if @order.status != "cancelled"
  #       @order.update(status: "cancelled")
  #       flash[:success] = "Successfully cancelled order #{@order.id}. Customer will be notified."
  #     end
  #   end
  # end

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
