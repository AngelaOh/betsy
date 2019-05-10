require "test_helper"

describe CategoriesController do
  let(:category) { categories(:one) }
  describe "show" do
    it "should get show" do
      get category_path(category.id)
      must_respond_with :success
    end
  end
end
