require "test_helper"
require "pry"

describe OrderItem do
  let(:order_item) { order_items(:one) }

  it "must be valid" do
    expect(order_item.valid?).must_equal true
  end

  it "must require a quantity" do
    expect(order_items(:two).valid?).must_equal false
    expect(order_items(:two).errors.messages).must_include :quantity
  end

  describe "relationships" do
    it "must belong to a product" do
      order_item.must_respond_to :product
      order_item.product.must_be_kind_of Product
    end

    it "must belong to an order" do
      order_item.must_respond_to :order
      order_item.order.must_be_kind_of Order
    end
  end
end
