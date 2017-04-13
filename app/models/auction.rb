class Auction < ApplicationRecord
  validates :name, :start_price, :bet_price, :current_price,
    :description, :end_price, :auction_time, :channel, presence: true
  validates :image_1, :image_2, file_size: { less_than: 10.megabytes }
  mount_uploader :image_1, ImageUploader
  mount_uploader :image_2, ImageUploader

  def add_participant(participant)
    if participants.exclude?(participant.stringify_keys)
      update(participants: participants << participant)
    end
  end

  def save_in_history(event)
    update(history: history << event)
  end

  def bet
    update(current_price: self.current_price += bet_price)
  end

  def set_price(price)
    update(current_price: price)
  end

  def check(participant_user_id)
    BannedUser.where(user_id: participant_user_id).empty?
  end
end
