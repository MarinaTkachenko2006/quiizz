class Answer < ApplicationRecord
  belongs_to :question
  
  validates :answer_text, presence: true, length: { maximum: 200 }
  validates :is_correct, inclusion: { in: [true, false] }

  before_validation :set_default_is_correct
  
  scope :correct, -> { where(is_correct: true) }
  scope :incorrect, -> { where(is_correct: false) }
  
  private
  
  def set_default_is_correct
    self.is_correct = false if self.is_correct.nil?
  end
end