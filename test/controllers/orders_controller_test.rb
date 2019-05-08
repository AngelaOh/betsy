require "test_helper"

describe OrdersController do
  let(:order) { orders(:first) }
  let(:order_item1) { order_items(:one) }
  let(:order_item2) { order_items(:two) }
  let(:product) { products(:manny) }

  describe "cart" do
    it "creates new order and holds associated order_items if order doesnt not already exist" do
      get cart_path

      expect(session[:order_id]).must_equal Order.last.id
    end
    it "if order already exists, the order and its orderitems persists across a session" do
      get cart_path
      expect(session[:order_id]).must_equal Order.last.id
      expected_order_id = Order.last.id

      get cart_path
      expect(session[:order_id]).must_equal expected_order_id
    end
  end

  describe "new order item" do
    it "adding a new item to the shopping cart adds an orderitem to an empty order" do
      get root_path
      empty_order = Order.find_by(id: session[:order_id])
      expect(empty_order).must_equal nil

      expect {
        post add_item_path(product.id), params: { quantity: 1 }
      }.must_change "OrderItem.count", 1

      new_order = Order.find_by(id: session[:order_id])
      expect(new_order.order_items.length).must_equal 1

      expect(flash[:success]).must_equal "manny added to the shopping cart."
      must_respond_with :redirect
    end

    it "updates the inventory for correct product when a new orderitem was created - flashes success and redirects" do
      product_inventory = product.inventory

      expect {
        post add_item_path(product.id), params: { quantity: 1 }
      }.must_change "OrderItem.count", 1
      product.reload

      expect(product.inventory).must_equal product_inventory - 1
      expect(flash[:success]).must_equal "#{product.name} added to the shopping cart."

      must_respond_with :redirect
    end

    it "updates the inventory for correct product when an existing orderitem is added to (via product#show)" do
      product_inventory = product.inventory
      post add_item_path(product.id), params: { quantity: 1 }
      product.reload
      expect(product.inventory).must_equal product_inventory - 1

      post add_item_path(product.id), params: { quantity: 1 }
      product.reload
      expect(product.inventory).must_equal product_inventory - 2
    end

    it "updates the quantity for correct orderitem when an existing orderitem is added to (via product#show)" do
      post add_item_path(product.id), params: { quantity: 1 }
      new_order = Order.find_by(id: session[:order_id])
      new_order_item = new_order.order_items[0]

      post add_item_path(product.id), params: { quantity: 1 }
      new_order_item.reload
      expect(new_order_item.quantity).must_equal 2
    end

    it "flashes an error and redirects if the the quantity to update is larger than the available inventory" do
      post add_item_path(product.id), params: { quantity: 70 }
      expect(flash[:error]).must_equal "We don't have enough items in inventory to fulfill this order."
      must_respond_with :redirect
    end
  end

  describe "update order item quantity" do
    it "updates product inventory" do
    end

    it "updates orderitem quantity" do
    end

    it "flashes error and redirects if the desired quantity is more than the inventory available" do
    end
  end

  describe "update" do
    it "updates an order with the checkout information" do
    end

    it "flashes error and redirects if order no longer exists" do
    end
  end

  describe "destroy" do
    it "should be able to delete a valid order item in a cart" do
      expect(order.order_items).must_include order_item1

      expect {
        delete delete_item_path(order_item1.product_id)
      }.must_change "OrderItem.count", -1

      expect(order.order_items).wont_include order_item1
      expect(flash[:success]).must_equal "Successfully deleted item from cart."

      must_respond_with :redirect
      must_redirect_to cart_path
    end

    it "should send an error message and redirect for an invalid order item" do
      invalid_order_item_id = "bogus"

      expect(order.order_items).wont_include order_item2

      expect {
        delete delete_item_path(invalid_order_item_id)
      }.wont_change "OrderItem.count"

      expect(flash[:error]).must_equal "This item is not currently in your cart."

      must_respond_with :redirect
      must_redirect_to cart_path
    end
  end

  describe "show" do
    it "destroys orderitems after user (non-merchant) checks out" do
    end
  end
end
