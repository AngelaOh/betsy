require "test_helper"

describe CategoriesController do
  let(:category) { categories(:one) }
  describe "index" do
    it "should get index" do
      get categories_path
      must_respond_with :success
    end
  end
  describe "show" do
    it "should get show" do
      get categories_path(category.id)
      must_respond_with :success
    end
  end
end
