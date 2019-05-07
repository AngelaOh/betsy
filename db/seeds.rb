# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

#questions about databases
#would seed be something where we would use to restore the database to last known state?
#like after reseting does it have to have the info from all the last adds
#also how does updating the csv file work
#and if belongs to validates, why isn't it requireing me to have a category
require "csv"

CATEGORY_FILE = Rails.root.join("db", "seed_data", "categories.csv")
puts "Loading raw user data from #{CATEGORY_FILE}"

category_failures = []
CSV.foreach(CATEGORY_FILE, :headers => true) do |row|
  category = Category.new
  category.id = row["id"]
  category.name = row["category"]
  successful = category.save
  if !successful
    category_failures << category
    puts "Failed to save category: #{category.inspect}"
  else
    puts "Created category: #{category.inspect}"
  end
end

puts "Added #{Category.count} merchant records"
puts "#{category_failures.length} merchants failed to save"

MERCHANT_FILE = Rails.root.join("db", "seed_data", "merchants.csv")
puts "Loading raw user data from #{MERCHANT_FILE}"

merchant_failures = []
CSV.foreach(MERCHANT_FILE, :headers => true) do |row|
  user = User.new
  user.id = row["id"]
  user.username = row["username"]
  user.email = row["email"]
  successful = user.save
  if !successful
    merchant_failures << user
    puts "Failed to save merchant: #{user.inspect}"
  else
    puts "Created merchant: #{user.inspect}"
  end
end

puts "Added #{User.count} merchant records"
puts "#{merchant_failures.length} merchants failed to save"

PRODUCT_FILE = Rails.root.join("db", "seed_data", "products.csv")
puts "Loading raw product data from #{PRODUCT_FILE}"

product_failures = []
CSV.foreach(PRODUCT_FILE, :headers => true) do |row|
  product = Product.new
  product.id = row["id"]
  product.name = row["name"]
  product.price = row["price"]
  product.inventory = row["inventory"]
  product.photo_url = row["photo_url"]
  product.description = row["description"]
  product.user_id = row["user_id"]
  cat = row["category"].split(".")
  cat.each do |x|
    #hacky and probably should add different way of doing it, but, refactor time
    product.categories << Category.find_by(id: x)
  end
  successful = product.save
  if !successful
    product_failures << product
    puts "Failed to save product: #{product.inspect}"
  else
    puts "Created product: #{product.inspect}"
  end

  #so add it to my spreadsheet anyhow, and then do products.categories
  #then parse through that input and create any categories that dont exist
  #iterate over each category
  #if it exists, add it
  #if it doesnt, create it
end

puts "Added #{Product.count} product records"
puts "#{product_failures.length} products failed to save"

puts "Manually resetting PK sequence on each table"
ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

puts "done"

Order.create(status: "pending")
OrderItem.create(quantity: 2, product_id: 1, order_id: 1)
OrderItem.create(quantity: 1, product_id: 4, order_id: 1)

Order.create(status: "paid")
OrderItem.create(quantity: 1, product_id: 1, order_id: 2)
OrderItem.create(quantity: 1, product_id: 3, order_id: 2)
