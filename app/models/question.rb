class Question < ApplicationRecord
  belongs_to :quiz
  has_many :answers, dependent: :destroy
  
  accepts_nested_attributes_for :answers,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['answer_text'].blank? }
  
  validates :text, presence: true, length: { maximum: 500 }
  validates :reward, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :time_limit, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  validate :at_least_one_answer
  validate :at_least_one_correct_answer
  
  before_validation :set_defaults
  
  private
  
  def set_defaults
    self.reward ||= 10
    self.time_limit ||= 30
    self.order_index ||= 1 if self.order_index.blank?
  end
  
  def at_least_one_answer
    if answers.empty? || answers.all? { |a| a.marked_for_destruction? || a.answer_text.blank? }
      errors.add(:base, "Вопрос должен иметь хотя бы один ответ")
    end
  end
  
  def at_least_one_correct_answer
    if answers.none? { |a| a.is_correct && !a.marked_for_destruction? }
      errors.add(:base, "Вопрос должен иметь хотя бы один правильный ответ")
    end
  end
end