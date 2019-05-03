require "test_helper"

describe ProductsController do
  let(:product) { Product.first }
  let(:user) { User.first }

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
      get product_path(product.id)

      must_respond_with :success
    end

    it "should redirect and send an error message for an invalid id" do
      invalid_id = -1

      get product_path(invalid_id)

      expect(flash[:error]).must_equal "That product does not exist"
      must_respond_with :redirect
      must_redirect_to products_path
    end
  end

  describe "new" do
    it "succeeds in generating a new form" do
      get new_user_product_path(user.id, product.id)

      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a product with valid data for a real merchant(logged-in user)" do
      new_product = {
        product: {
          name: "new_product", price: 2, inventory: 20, photo_url: "url", description: "cool item", user_id: user.id,
        },
      }

      expect {
        post user_products_path(user.id), params: new_product
      }.must_change "Product.count", 1

      new_product = Product.find_by(name: "new_product")

      expect(flash[:success]).must_equal "Successfully created new product #{new_product.name}"
      must_respond_with :redirect
      must_redirect_to product_path(new_product.id)
    end

    it "renders bad_request and redirects for invalid data" do
      bad_product = { product: { name: nil } }

      expect {
        post user_products_path(user.id), params: bad_product
      }.wont_change "Product.count"
      expect(flash[:error]).must_equal "Could not create new product "
      # TODO: do we need to test for flash[:messages? Seems unnecessary. ]
      must_respond_with :bad_request
    end
  end

  describe "edit" do
    it "succeeds for existing product and user IDs" do
      get edit_user_product_path(user.id, product.id)

      must_respond_with :success
    end

    # it "renders 404 not_found for a bogus user ID" do
    #   bogus_id = "INVALID ID"
    #   get edit_user_product_path(-1, product.id)

    #   must_respond_with :not_found
    # end
  end
  
  describe "update" do
    it "will update an existing product" do
      product_to_update = products(:one)
      product_updates = {
        product: {
          name: "update name",
        },
      }

      expect {
        patch user_product_path(user.id, product_to_update.id), params: product_updates
      }.wont_change "Product.count"

      product_to_update.reload
      expect(product_to_update.name).must_equal "update name"
      must_respond_with :redirect
      must_redirect_to product_path(product.id)
    end

    it "will return a bad request when asked to update with invalid data" do
    end

    it "will respond with 404 not_found for a bogus product ID " do
    end
  end

  # it "should get destroy" do
  #   get products_destroy_url
  #   value(response).must_be :success?
  # end

end
