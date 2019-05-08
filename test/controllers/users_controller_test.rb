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
      user = perform_login
      get user_path(user.id)

      must_respond_with :success
    end

    it "should get respond with 404 not found if ID is invalid and user is logged in" do
      user = perform_login
      get user_path(-7)
      must_redirect_to root_path
      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal "User not found."
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
      start_count = User.count
      new_user = User.new(provider: "github", username: "peter", uid: 987, email: "peter@griffin.com")
      perform_login(new_user)

      user = User.find_by(id: session[:user_id])
      User.count.must_equal start_count + 1

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

  describe "logout" do
    it "can logout user" do
      perform_login
      logout_data = {
        user: {
          username: user.username,
        },
      }

      delete logout_path, params: logout_data
      expect(session[:user_id]).must_be_nil
      expect(flash[:notice]).must_equal "Logged out #{user.username}"
      must_redirect_to root_path
    end
  end
end
