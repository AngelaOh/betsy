require "test_helper"
require "pry"

describe Product do
  let(:product) { products(:manny) }

  it "must be valid" do
    expect(product.valid?).must_equal true
  end

  describe "relations" do
    let(:category) { categories(:one) }
    let(:user) { users(:one) }
    let(:orderitems) { order_items(:one) }
    let(:order) { orders(:first) }
    it "has and belongs to many catagories" do
      expect(product).must_respond_to :categories
      expect(product.categories.first).must_be_kind_of Category
      expect(product.categories.length).must_equal 2

      expect(category).must_respond_to :products
      expect(category.products.first).must_be_kind_of Product
      expect(category.products.length).must_equal 2
    end

    it "belongs to users" do
      product.user.must_be_kind_of User
      product.must_respond_to :user
      product.user.username.must_equal "Alex"

      #other way arount
      user.products.first.must_be_kind_of Product
      user.must_respond_to :products
      user.products.first.name.must_equal "manny"
    end

    it "has many order items" do
      product.must_respond_to :order_items
      product.order_items.first.must_be_kind_of OrderItem
      product.order_items.length.must_equal 2
    end

    it "has many orders through order items" do
      product.order_items.must_respond_to :order
      product.order_items.first.order.must_be_kind_of Order
    end
  end

  describe "validations" do
    let(:product2) { products(:two) }
    it "description is required" do
      product.description = ""
      product.save
      expect(product.valid?).must_equal false
      product.errors.messages.must_include :description
      product.errors[:description].include?("can't be blank")
    end

    it "requires a photo_url" do
      product.photo_url = ""
      product.save
      expect(product.valid?).must_equal false
      product.errors.messages.must_include :photo_url
      product.errors[:photo_url].include?("can't be blank")
    end

    it "requires a name" do
      product.name = ""
      product.save
      expect(product.valid?).must_equal false
      product.errors.messages.must_include :name
      product.errors[:name].include?("can't be blank")
    end

    it "requires a unique name" do
      product2.name = "manny"
      product2.save
      expect(product2.valid?).must_equal false
      product2.errors.messages.must_include :name
      product2.errors[:name].include?("has already been taken")
    end

    it "requires a price" do
      product.price = ""
      product.save
      expect(product.valid?).must_equal false
      product.errors.messages.must_include :price
      product.errors[:price].include?("can't be blank")
    end

    it "requires a price greater than 0" do
      product.price = 0
      product.save
      expect(product.valid?).must_equal false
      product.errors.messages.must_include :price
      product.errors[:price].include?("must be greater than 0")
    end
  end
end
