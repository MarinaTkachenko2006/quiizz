class Question < ApplicationRecord
  belongs_to :quiz
  has_many :answers, dependent: :destroy
  
  accepts_nested_attributes_for :answers,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['answer_text'].blank? }
  
  validates :text, presence: true, length: { maximum: 500 }
  validates :reward, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :time_limit, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  before_validation :set_defaults
  
  
  def correct_answer_count
    correct_answers.count
  end

  private
  
  def set_defaults
    self.reward ||= 10
    self.time_limit ||= 30
    self.order_index ||= 1 if self.order_index.blank?
  end

  def correct_answers
    answers.where(is_correct: true)
  end
  
  
  def check_answers(selected_answer_ids)
    correct_ids = correct_answers.pluck(:id)
    selected_ids = Array(selected_answer_ids).map(&:to_i)
    {
      selected: selected_ids,
      correct: correct_ids,
      is_correct: (selected_ids.sort == correct_ids.sort)
    }
  end
end