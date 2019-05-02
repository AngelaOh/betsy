class AddsAllForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_refrence :products, :user, foreign_key: true
    add_refrence :orderitems, :product, foreign_key: true
    add_refrence :orderitems, :order, foreign_key: true
  end
end
