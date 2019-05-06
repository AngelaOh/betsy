require "test_helper"

describe OrdersController do
  let(:order) { orders(:first) }
  let(:order_item1) { order_items(:one) }
  let(:order_item2) { order_items(:two) }

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
end
