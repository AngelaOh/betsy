class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :status
      t.datetime :time_placed
      t.string :name
      t.string :email
      t.string :address
      t.integer :credit_card
      t.integer :exp

      t.timestamps
    end
  end
end
