class CreateBannedUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :banned_users do |t|
      t.string :user_id
      t.string :first_name
      t.string :last_name
    end
  end
end
