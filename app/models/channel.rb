class Channel < ApplicationRecord
  validates :name, :link, :rules, presence: true
end
