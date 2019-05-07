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
      order_item.must_respond_to :order
      # but why won't order.respond_to :order_item
      # and is this the fixture its talking about, or the model
      results.first.must_be_kind_of OrderItem
    end

    it "has many products through order_items" do
      results = OrderItem.where(order_id: order.id)
      results.first.must_respond_to :product
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
      expect(order3.errors.messages).must_include :status
    end

    it "accepts correct (existing) checkout information" do

      order.name = "Skippy McGee"
      order.email =  "skippy@mcgee.org"
      order.address = "123 Happy St."
      order.credit_card = 12345678912
      order.exp = 1221

      order.valid?.must_equal true
    end

    it "rejects invalid checkout information" do
      order.name = ""
      order.email =  "skippy@mcgee.org"
      order.address = "123 Happy St."
      order.credit_card = 12345678912
      order.exp = 1221

      order.valid?.must_equal false
    end
  end
end
