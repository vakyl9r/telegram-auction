class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :registration_code, presence: true
  validate  :verife_code

  private

  def verife_code
    return if registration_code == Rails.application.secrets.registration_code
    errors.add(:registration_code, 'Registration Code is invalid')
  end
end
