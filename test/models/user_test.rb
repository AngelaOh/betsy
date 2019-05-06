require "test_helper"

describe User do
  let(:user) { users(:one) }

  it "must be valid" do
    expect(user.valid?).must_equal true
  end

  describe "relations" do
    #haven't I basically done this in other models where it wouldn't be needed here?
    it "has many products" do
      user.must_respond_to :products
      user.products.first.must_be_kind_of Product
      user.products.first.name.must_equal "manny"
    end
  end

  describe "validations" do
    let(:user2) { users(:two) }
    it "must have a username" do
      user.username = ""
      user.save
      expect(user.valid?).must_equal false
      user.errors.messages.must_include :username
      user.errors[:username].first.must_equal "can't be blank"
    end

    it "must have a unique username" do
      user2.username = "Alex"
      user2.save
      expect(user2.valid?).must_equal false
      user2.errors.messages.must_include :username
      user2.errors[:username].first.must_equal "has already been taken"
    end

    it "must have an email" do
      user.email = ""
      user.save
      # expect(user.valid?).must_equal false
      user.errors.messages.must_include :email
      user.errors[:email].first.must_equal "can't be blank"
    end

    it "must have a unique email" do
      user2.email = "alex@alex.org"
      user2.save
      expect(user2.valid?).must_equal false
      user2.errors.messages.must_include :email
      user2.errors[:email].first.must_equal "has already been taken"
    end
  end
end
