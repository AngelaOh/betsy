require "test_helper"

describe OrdersController do
  it "should get show" do
    get orders_show_url
    value(response).must_be :success?
  end

end
