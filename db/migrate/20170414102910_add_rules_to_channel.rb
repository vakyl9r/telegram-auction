class AddRulesToChannel < ActiveRecord::Migration[5.0]
  def change
    add_column :channels, :rules, :text
  end
end
