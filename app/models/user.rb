class User < ApplicationRecord
  has_many :products
  validates :username, :email, uniqueness: true

  def self.build_from_github(auth_hash)
    return User.new(uid: auth_hash[:uid], provider: "github",
                    email: auth_hash["info"]["email"],
                    username: auth_hash["info"]["name"])
  end
end
