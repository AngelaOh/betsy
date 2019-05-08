class ChangeRetiredColumnToHandleNull < ActiveRecord::Migration[5.2]
  def change
    change_column(:products, :retired, :boolean, default: false, null: false)
  end
end
