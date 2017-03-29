class AddRegistrationCodeForUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :registration_code, :string
  end
end
