# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  validates :nickname, presence: true, 
                       uniqueness: true, 
                       length: { minimum: 4, maximum: 20 }
  validates :email, presence: true, 
                    uniqueness: true, 
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }
  
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: :email_changed?

  has_many :quizzes, foreign_key: 'author_id', dependent: :destroy
  has_many :scores, dependent: :destroy

  before_save :downcase_email

  def formatted_created_at
    created_at.strftime("%d.%m.%Y в %H:%M")
  end

  def formatted_updated_at
    updated_at.strftime("%d.%m.%Y в %H:%M")
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end