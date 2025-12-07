class Answer < ApplicationRecord
  belongs_to :question
  
  validates :answer_text, presence: true, length: { maximum: 200 }
  validates :is_correct, inclusion: { in: [true, false] }

  scope :correct, -> { where(is_correct: true) }
  scope :incorrect, -> { where(is_correct: false) }
end