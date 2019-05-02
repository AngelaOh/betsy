require "test_helper"

# let(:product) { products(:one) }

describe ProductsController do
  describe "index" do
    it "succeeds when there are products" do
      get products_path

      must_respond_with :success
    end

    it "succeeds when there are no products" do
      Product.all do |product|
        product.destroy
      end

      get products_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "succeeds for an existing product ID" do
      product = Product.first
      get user_product_path(product.id)

      must_respond_with :success
    end

    # it "renders 404 not_found for a bogus work ID" do
    #   destroyed_id = existing_work.id
    #   existing_work.destroy

    #   get work_path(destroyed_id)

    #   must_respond_with :not_found
    # end
  end

  describe "new" do
    it "succeeds in generating a new form" do
      existing_user = User.first
      get new_user_product_path(existing_user.id)

      must_respond_with :success
    end
  end
  describe "create" do
    it "creates a product with valid data for a real merchant(logged-in user)" do
      existing_user = User.first
      new_product = {product: {name: "new_product", price: 2, inventory: 20}}

      expect {
        post user_products_path(existing_user.id), params: new_product
      }.must_change "Product.count", 1

      new_product_id = Work.find_by(name: "new_product").id

      must_respond_with :redirect
      # must_redirect_to user_product_path(@product.user.id)
    end

    it "renders bad_request and redirects for invalid data" do
      existing_user = User.first
      bad_product = {product: {name: nil}}

      expect {
        post user_products_path(existing_user.id), params: bad_product
      }.wont_change "Product.count"

      must_respond_with :bad_request
    end
  end

  describe "edit" do
    # it "succeeds for existing product and user IDs" do
    #   get edit_user_product_path(existing_work.id)

    #   must_respond_with :success
    # end

    # it "renders 404 not_found for a bogus product ID" do
    #   bogus_id = existing_work.id
    #   existing_work.destroy

    #   get edit_user_product_path()

    #   must_respond_with :not_found
    # end

    # it "renders 404 not_found for a bogus user ID" do
    #   bogus_id = existing_work.id
    #   existing_work.destroy

    #   get edit_user_product_path()

    #   must_respond_with :not_found
    # end
  end
  # it "should get update" do
  #   get products_update_url
  #   value(response).must_be :success?
  # end

  # it "should get destroy" do
  #   get products_destroy_url
  #   value(response).must_be :success?
  # end

end
