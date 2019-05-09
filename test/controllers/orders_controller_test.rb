require "test_helper"

describe OrdersController do
  let(:order) { orders(:first) }
  let(:paid_order) { orders(:three) }
  let(:cancelled_order) { orders(:four) }
  let(:shipped_order) { orders(:two) }
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

  describe "new" do
    it "will flash an error and redirect if order is invalid" do
      invalid_order_id = -1
      get checkout_form_path

      expect(flash[:error]).must_equal "This order does not exist"
      must_respond_with :redirect
    end
  end

  describe "update order item quantity" do
    it "updates product inventory" do
      product_inventory = product.inventory
      post add_item_path(product.id), params: { quantity: 1 }
      product.reload
      expect(product.inventory).must_equal product_inventory - 1

      patch update_quantity_path(product.id), params: { order_item: { quantity: 3 } }
      product.reload
      expect(product.inventory).must_equal product_inventory - 3
    end

    it "updates orderitem quantity" do
      post add_item_path(product.id), params: { quantity: 1 }
      order_item = OrderItem.find_by(order_id: session[:order_id])
      order_item.reload

      patch update_quantity_path(product.id), params: { order_item: { quantity: 3 } }
      expect(OrderItem.find_by(order_id: session[:order_id]).quantity).must_equal 3
    end

    it "flashes error and redirects if the desired quantity is more than the inventory available" do
      post add_item_path(product.id), params: { quantity: 1 }

      patch update_quantity_path(product.id), params: { order_item: { quantity: 100000 } }
      expect(flash[:error]).must_equal "We don't have enough items in inventory to fulfill this order."
    end
  end

  describe "update" do
    it "updates an order with the checkout information" do
      # patch "/orders/:id", to: "orders#update", as: "order_update"
      post add_item_path(product.id), params: { quantity: 1 }
      new_order = Order.find_by(id: session[:order_id])
      expect(new_order.order_items.length).must_equal 1

      patch order_update_path(new_order.id), params: { order: { status: "pending", name: "blah", email: "blah", address: "blah", credit_card: 999, exp: 999 } }
      new_order.reload

      must_respond_with :redirect
      expect(new_order.name).must_equal "blah"
    end

    it "flashes error and redirects if order no longer exists" do
      order = Order.create(status: "pending")
      order_id = Order.create(status: "pending").id
      order.destroy
      patch order_update_path(order_id), params: { order: { status: "pending", name: "blah", email: "blah", address: "blah", credit_card: 999, exp: 999 } }

      expect(flash[:error]).must_equal "This order does not exist"
      must_respond_with :redirect
    end

    it "responds with bad request if data is not valid" do
      post add_item_path(product.id), params: { quantity: 1 }
      new_order = Order.find_by(id: session[:order_id])
      expect(new_order.order_items.length).must_equal 1

      patch order_update_path(new_order.id), params: { order: { status: "pending", name: "", email: "blah", address: "blah", credit_card: 999, exp: 999 } }
      new_order.reload

      must_respond_with :bad_request
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
    it "sets current session[:order_id] to be nil" do
      post add_item_path(product.id), params: { quantity: 1 }
      new_order = Order.find_by(id: session[:order_id])
      expect(session[:order_id]).wont_be_nil

      get order_path(new_order.id)
      expect(session[:order_id]).must_be_nil
    end

    it "flashes an error and redirects if order is nil" do
      get order_path(-1)
      expect(flash[:error]).must_equal "This order does not exist"
      must_respond_with :redirect
    end
  end

  describe "ship_order" do
    it "changes status to complete for a valid paid order" do
      expect(paid_order.status).must_equal "paid"

      patch ship_order_path(paid_order.id)

      paid_order.reload

      expect(paid_order.status).must_equal "complete"
      expect(flash[:success]).must_equal "You have shipped Order #{paid_order.id}'s items."

      must_respond_with :redirect
    end

    it "does not change the status for a valid pending order" do
      expect(order.status).must_equal "pending"

      patch ship_order_path(order.id)

      order.reload

      expect(order.status).must_equal "pending"
      expect(flash[:error]).must_equal "This order is not ready to be shipped."

      must_respond_with :redirect
    end

    it "does not change the status for a valid cancelled order" do
      expect(cancelled_order.status).must_equal "cancelled"

      patch ship_order_path(cancelled_order.id)

      cancelled_order.reload

      expect(cancelled_order.status).must_equal "cancelled"
      expect(flash[:error]).must_equal "This order has been cancelled and cannot be shipped."

      must_respond_with :redirect
    end

    it "does not change the status for a valid complete/shipped order" do
      expect(shipped_order.status).must_equal "complete"

      patch ship_order_path(shipped_order.id)

      shipped_order.reload

      expect(shipped_order.status).must_equal "complete"

      expect(flash[:error]).must_equal "You have already shipped items in this order."

      must_respond_with :redirect
    end

    it "will send an error and redirect for an invalid order" do
      invalid_order_id = -1

      patch ship_order_path(invalid_order_id)

      expect(flash[:error]).must_equal "This order does not exist"

      must_respond_with :redirect
    end
  end

  describe "cancel_order" do
    it "cancels order if order is paid" do
      expect(paid_order.status).must_equal "paid"

      patch cancel_order_path(paid_order.id)
      paid_order.reload

      expect(paid_order.status).must_equal "cancelled"
      expect(flash[:success]).must_equal "Successfully cancelled order #{paid_order.id}. Customer will be notified."
    end

    it "cancels order if order is pending" do
      expect(order.status).must_equal "pending"

      patch cancel_order_path(order.id)
      order.reload

      expect(order.status).must_equal "cancelled"
      expect(flash[:success]).must_equal "Successfully cancelled order #{order.id}. Customer will be notified."
    end

    it "will send an error and redirect if status is cancelled already" do
      expect(cancelled_order.status).must_equal "cancelled"

      patch cancel_order_path(cancelled_order.id)

      expect(cancelled_order.status).must_equal "cancelled"
      expect(flash[:error]).must_equal "Order #{cancelled_order.id} cannot be cancelled! Please review its status."
      must_respond_with :redirect
    end

    it "will send an error and redirect if status is complete already" do
      expect(shipped_order.status).must_equal "complete"

      patch cancel_order_path(shipped_order.id)

      expect(shipped_order.status).must_equal "complete"
      expect(flash[:error]).must_equal "Order #{shipped_order.id} cannot be cancelled! Please review its status."
      must_respond_with :redirect
    end

    it "will send an error and redirect for an invalid order" do
      invalid_order_id = -1

      patch cancel_order_path(invalid_order_id)

      expect(flash[:error]).must_equal "This order does not exist"

      must_respond_with :redirect
    end
  end
end
