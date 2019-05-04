require "test_helper"
require "pry"
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
      must_redirect_to root_path
      expect(flash[:result_text]).must_equal "User not found!"
      expect(flash[:status]).must_equal :failure
    end
  end

  describe "login" do
    it "can log in an existing user" do
      user = perform_login

      expect {
        user = perform_login(user)
      }.wont_change "User.count"

      expect(session[:user_id]).must_equal user.id
      expect(flash[:success]).must_equal "Logged in as returning user #{user.username}"
    end

    it "can log in a new user" do
      # Arrange
      user = User.new(provider: "github", username: "peter", uid: 987, email: "peter@griffin.com")

      expect {
        # Act
        perform_login(user)
        # Assert
      }.must_change "User.count", 1

      user = User.find_by(uid: user.uid, provider: user.provider)

      expect(session[:user_id]).must_equal user.id
      expect(flash[:success]).must_equal "Logged in as new user #{user.username}"
    end
    it "Flashes an error if user could not be created." do
      OmniAuth.config.mock_auth[:github] = nil

      get auth_callback_path(:github)

      expect {
        get auth_callback_path(:github)
      }.wont_change "User.count"

      must_respond_with :redirect
      must_redirect_to root_path

      expect(flash[:result_text]).must_equal "Could not create new user account."
    end

    it "responds with a redirect if no user is logged in" do
      get current_user_path
      must_respond_with :redirect
    end
  end

  # describe "current" do
  #   it "recognizes a current user" do
  #     # will update when we do OAuth testing
  #     user = users(:one)
  #     perform_login(user)
  #     # Arrange: We have to log in as a user by NOT manipulating session... we will do a login action!

  #     # Act: We need to still make a request to get to the users controller current action
  #     get current_user_path

  #     must_respond_with :success

  #     # binding.pry

  #   end
  #   it "responds with error and redirect if a user is not logged in" do
  #     # will update when we do OAuth testing
  #     user = users(:one)
  #     # Arrange: We have to log in as a user by NOT manipulating session... we will do a login action!

  #     # Act: We need to still make a request to get to the users controller current action
  #     get current_user_path

  #     must_respond_with :redirect
  #     must_redirect_to users_path
  #     binding.pry
  #     expect(flash[:error]).must_equal "You must be logged in first!"
  #   end
  # end

  describe "logout" do
    it "can logout user" do
      # arrange
      perform_login
      logout_data = {
        user: {
          username: user.username,
        },
      }
      #act
      delete logout_path, params: logout_data
      expect(session[:user_id]).must_be_nil
      expect(flash[:notice]).must_equal "Logged out #{user.username}"
      must_redirect_to root_path
    end
  end
end
