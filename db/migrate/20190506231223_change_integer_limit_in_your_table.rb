class ChangeIntegerLimitInYourTable < ActiveRecord::Migration[5.2]
  def change
    change_column :orders, :credit_card, :integer, limit: 8
  end
end
