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
      must_respond_with :redirect
      expect(flash[:result_text]).must_equal "User not found!"
    end
  end

  describe "login" do
    it "can log in an existing user" do
      # Arrange
      user_count = User.count

      # Act
      user = perform_login

      expect(user_count).must_equal User.count

      # Should also test Flash notices

      expect(session[:user_id]).must_equal user.id
    end

    it "can log in a new user" do
      # Arrange
      user = User.new(provider: "github", username: "peter", uid: 987, email: "peter@griffin.com")

      expect {
        # Act
        perform_login(user)
        # Assert
      }.must_change "User.count", 1

      # Should also test Flash notices
      user = User.find_by(uid: user.uid, provider: user.provider)

      expect(session[:user_id]).must_equal user.id
    end
  end

  it "responds with a redirect if no user is logged in" do
    get current_user_path
    must_respond_with :redirect
  end
end
