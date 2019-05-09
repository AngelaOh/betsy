require "test_helper"
#TODO: add simplecov for test coverage after merging

describe ProductsController do
  let(:product) { Product.first }
  let(:user) { User.first }

  describe "root/homepage" do
    it "succeeds in showing products" do
      get root_path

      must_respond_with :success
    end

    it "succeeds in showing homepage with no products" do
      Product.all do |product|
        product.destroy
      end

      get root_path

      must_respond_with :success
    end
  end

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
      perform_login(user)

      get new_user_product_path(user.id)

      must_respond_with :success
    end
  end

  describe "create" do
    it "creates a product with valid data for a real merchant(logged-in user)" do
      perform_login(user)

      new_product = {
        product: {
          name: "new_product", price: 2, inventory: 20, photo_url: "url", description: "cool item",
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
      perform_login(user)

      bad_product = { product: { name: nil } }

      expect {
        post user_products_path(user.id), params: bad_product
      }.wont_change "Product.count"
      expect(flash[:error]).must_equal "Could not create new product "
      # TODO: do we need to test for flash[:messages? Seems unnecessary but also idk how lol
      must_respond_with :bad_request
    end
  end

  describe "edit" do
    it "succeeds for existing product and user IDs" do
      perform_login(user)

      get edit_user_product_path(user.id, product.id)

      must_respond_with :success
    end

    it "responds with 404 not_found for a bogus product ID" do
      perform_login(user)

      bogus_id = "INVALID ID"
      get edit_user_product_path(user.id, bogus_id)

      must_respond_with :not_found
    end
  end

  describe "update" do
    it "will update an existing product" do
      perform_login(user)
      # TODO: figure out how to make product.yml file legit
      product_to_update = Product.create(name: "name", price: 1, inventory: 1, photo_url: "hi", description: "something", user_id: user.id)

      product_updates = { product: { name: "update name" } }

      expect {
        patch user_product_path(user.id, product_to_update.id), params: product_updates
      }.wont_change "Product.count"

      product_to_update.reload
      expect(product_to_update.name).must_equal "update name"
      expect(flash[:success]).must_equal "#{product_to_update.name} updated successfully!"
      must_respond_with :redirect
      must_redirect_to product_path(product_to_update.id)
    end

    it "will return a bad request when asked to update with invalid data" do
      perform_login(user)

      product_to_update = Product.create(name: "name", price: 1, inventory: 1, photo_url: "hi", description: "something", user_id: user.id)

      product_updates = { product: { name: "" } }

      expect {
        patch user_product_path(user.id, product_to_update.id), params: product_updates
      }.wont_change "Product.count"

      product_to_update.reload
      expect(flash[:error]).must_equal "Could not edit this product."
      must_respond_with :bad_request
    end

    it "will respond with 404 not_found for a bogus product ID " do
      perform_login(user)

      bogus_id = "INVALID ID"
      patch user_product_path(user.id, bogus_id)
      must_respond_with :not_found
    end
  end

  describe "retire" do
    it "changes a valid product to 'retired'" do
      perform_login(user)

      product_to_update = Product.create(name: "name", price: 1, inventory: 1, photo_url: "hi", description: "something", user_id: user.id)

      expect(product_to_update.retired).must_equal false

      patch product_retire_path(user.id, product_to_update.id)

      product_to_update.reload

      expect(product_to_update.retired).must_equal true
      expect(flash[:success]).must_equal "Successfully removed/retired #{product_to_update.name} from Toonsy"
      must_respond_with :redirect
    end

    it "changes a valid product's retired status back to false" do
      perform_login(user)

      product_to_update = Product.create(name: "name", price: 1, inventory: 1, photo_url: "hi", description: "something", user_id: user.id)

      patch product_retire_path(user.id, product_to_update.id)
      product_to_update.reload

      expect(product_to_update.retired).must_equal true

      patch product_retire_path(user.id, product_to_update.id)
      product_to_update.reload

      expect(product_to_update.retired).must_equal false
      expect(flash[:success]).must_equal "Product #{product_to_update.name} is now available to be sold on Toonsy"

      must_respond_with :redirect
    end

    it "will respond with 404 not_found for a bogus product ID " do
      perform_login(user)

      bogus_id = "INVALID ID"
      patch product_retire_path(user.id, bogus_id)
      must_respond_with :not_found
    end
  end
end
