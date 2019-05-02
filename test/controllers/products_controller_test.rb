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

  # it "should get new" do
  #   get products_new_url
  #   value(response).must_be :success?
  # end

  # it "should get create" do
  #   get products_create_url
  #   value(response).must_be :success?
  # end

  # it "should get edit" do
  #   get products_edit_url
  #   value(response).must_be :success?
  # end

  # it "should get update" do
  #   get products_update_url
  #   value(response).must_be :success?
  # end

  # it "should get destroy" do
  #   get products_destroy_url
  #   value(response).must_be :success?
  # end

end
