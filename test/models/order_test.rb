require "test_helper"

describe Order do
  let(:order) { orders(:first) }

  it "must be valid" do
    expect(order.valid?).must_equal true
  end

  describe "relations" do
    let(:order_item) { order_items(:one) }
    let(:product) { products(:manny) }
    it "has many orderitems" do
      results = OrderItem.where(order_id: order.id)
      # binding.pry
      # results.first.must_respond_to :order_item
      results.first.must_be_kind_of OrderItem
    end

    it "has many products through order_items" do
      results = OrderItem.where(order_id: order.id)
      # results.first.product.must_respond_to :product
      # can't get this test to work, hoping its because we don't have any methods yet
      results.first.product.must_be_kind_of Product
    end
  end

  describe "validations" do
    it "requires a valid status" do
      order2 = Order.new(status: "pending")
      order2.valid?.must_equal true
    end

    it "rejects an invalid status" do
      order3 = Order.new(status: "snooping")
      order3.valid?.must_equal false
    end
  end
end
