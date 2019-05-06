require "test_helper"

describe OrdersController do
  let(:order) { orders(:first) }
  let(:order_item) { order_items(:one) }

  describe "destroy" do
    it "should be able to delete a valid order item in a cart" do
      expect(order.order_items).must_include order_item

      delete delete_item_path(order_item.product_id)

      expect(order.order_items).wont_include order_item
      expect(flash[:success]).must_equal "Successfully deleted item from cart."
    end
  end
end
