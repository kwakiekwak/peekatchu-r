class AddImagesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :images, :string
  end
end
