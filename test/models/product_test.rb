require "test_helper"
require "pry"

describe Product do
  let(:product) { products(:one) }
  let(:product) { products(:two) }
  let(:user) { users(:two) }

  describe "validations" do
    it "must be valid when all fields are present" do
      result = products(:one).valid?

      expect(result).must_equal true
    end

    it "is invalid without a name" do
      products(:one).name = nil

      # Act
      result = products(:one).valid?

      # Assert
      expect(result).must_equal false
      expect(products(:one).errors.messages).must_include :name
    end

    it "product must have a unique name" do
      @product3 = Product.create(name: "hey", price: 2, inventory: 12, photo_url: "url", description: "description", user: users(:two))
      duplicate_product = @product3.dup
      result = duplicate_product.valid?

      expect(result).must_equal false
      expect(duplicate_product.errors.messages[:name]).include?("has already been taken")
    end

    it "is invalid without a price" do
      products(:two).price = nil

      # Act
      result = products(:two).valid?

      # Assert
      expect(result).must_equal false
      expect(products(:two).errors.messages).must_include :price
    end

    it "price must be an integer" do
      products(:two).price = "not an integer"

      result = products(:two).valid?
      expect(result).must_equal false

      expect(products(:two).errors.messages[:price]).include?("is not a number")
    end

    it "price must be greater than zero" do
      products(:two).price = -5

      negative_price = products(:two).valid?
      expect(negative_price).must_equal false

      expect(products(:two).errors.messages[:price]).include?("must be greater than zero")
    end

    it "description must be present " do
      products(:one).description = nil
      invalid_description = products(:one).valid?

      expect(invalid_description).must_equal false
      expect(products(:one).errors.messages[:description]).include?("can't be blank")
    end

    it "photo url must be present " do
      products(:one).photo_url = nil
      invalid_photo_url = products(:one).valid?
      expect(invalid_photo_url).must_equal true
      expect(products(:one).errors.messages[:photo_url]).include?("can't be blank")
    end
  end
end
