require "test_helper"

describe UsersController do
  let(:user) { users(:one) }
  let(:invalid_id) { "INVALID ID" }
  describe "index" do
    it "should get index when users exist" do
      get users_path

      must_respond_with :success
    end
    it "should get index when no users exist" do
      User.all do |user|
        user.destroy
      end

      get users_path

      must_respond_with :success
    end
  end

  describe "show" do
    it "should get respond with success if user exists" do
      get user_path(user.id)
      must_respond_with :success
    end

    it "should get respond with 404 not found if ID is invalid" do
      get user_path(invalid_id)
      must_respond_with :not_found
    end
  end
end
