class AddsPhotoUrLandDescriptionToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :photo_url, :string
    add_column :products, :description, :string
  end
end
