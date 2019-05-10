class OrdersController < ApplicationController
  before_action :find_session_order, only: [:cart, :new_order_item, :new, :update, :show]

  def cart
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
  end

  def new_order_item
    if @order.nil?
      @order = Order.create(status: "pending")
      session[:order_id] = @order.id
    end

    @item = OrderItem.find_by(order_id: @order.id, product_id: params[:id])

    if !@item.nil?
      if params[:quantity].to_i > Product.find_by(id: @item.product_id).inventory
        flash[:error] = "We don't have enough items in inventory to fulfill this order."
        redirect_to product_path(params[:id])
        return
      end
      @item.update(quantity: @item.quantity + params[:quantity].to_i)
      Product.find_by(id: @item.product_id).update(inventory: Product.find_by(id: @item.product_id).inventory - params[:quantity].to_i)
    else
      @item = OrderItem.create(quantity: params[:quantity], order_id: @order.id, product_id: params[:id])

      if params[:quantity].to_i > Product.find_by(id: @item.product_id).inventory
        flash[:error] = "We don't have enough items in inventory to fulfill this order."
        redirect_to product_path(params[:id])
        return
      end
      @order.order_items << @item
      Product.find_by(id: @item.product_id).update(inventory: Product.find_by(id: @item.product_id).inventory - @item.quantity)  #change inventory of Products
    end
    flash[:success] = "#{Product.find_by(id: @item.product_id).name} added to the shopping cart."
    redirect_to product_path(params[:id])
  end

  def update_order_item_quantity
    @order = find_session_order
    @update_item = OrderItem.find_by(order_id: @order.id, product_id: params[:id].to_i)
    updated_inventory = (Product.find_by(id: @update_item.product_id)).inventory - (params[:order_item][:quantity].to_i - @update_item.quantity)
    if updated_inventory <= 0
      flash[:error] = "We don't have enough items in inventory to fulfill this order."
      redirect_to cart_path
      return
    end
    Product.find_by(id: @update_item.product_id).update(inventory: updated_inventory)
    @update_item.update(quantity: params[:order_item][:quantity].to_i)
    redirect_to cart_path
  end

  def new
    if @order.nil? || @order.order_items.length == 0
      flash[:error] = "This order does not exist"
      redirect_to root_path
    end
  end

  def update
    if @order.nil? || @order.order_items.length == 0
      flash[:error] = "This order does not exist"
      redirect_to root_path
      return
    end

    @order.status = "paid"
    @order.time_placed = DateTime.now
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
  end

  def destroy
    @item = OrderItem.find_by(product_id: params[:id])

    if @item.nil?
      flash[:error] = "This item is not currently in your cart."
    else
      Product.find_by(id: @item.product_id).update(inventory: Product.find_by(id: @item.product_id).inventory + @item.quantity)
      @item.destroy
      flash[:success] = "Successfully deleted item from cart."
    end

    redirect_to cart_path
  end

  def show
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

  def cancel_order
    @order = Order.find_by(id: params[:id])
    if @order == nil
      flash[:error] = "This order does not exist"
    else
      if @order.status != "complete" && @order.status != "cancelled"
        @order.update(status: "cancelled")
        flash[:success] = "Successfully cancelled order #{@order.id}. Customer will be notified."
      else
        flash[:error] = "Order #{@order.id} cannot be cancelled! Please review its status."
      end
    end

    redirect_back fallback_location: root_path
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
