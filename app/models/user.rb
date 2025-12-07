class User < ApplicationRecord
  has_secure_password

  validates :nickname, presence: true, 
                       uniqueness: true, 
                       length: { minimum: 3, maximum: 50 }
  validates :email, presence: true, 
                    uniqueness: true, 
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || password.present? }

  has_many :quizzes, foreign_key: 'author_id', dependent: :nullify
  has_many :scores, dependent: :destroy

  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase
  end
end
