class CreateTelegramLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :telegram_logs do |t|
      t.string :user
      t.json :data
      t.string :action
      t.references :auction, foreign_key: true

      t.timestamps
    end
  end
end
