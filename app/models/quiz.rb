class Quiz < ApplicationRecord
  belongs_to :author, class_name: 'User'
  has_many :questions, dependent: :destroy

  accepts_nested_attributes_for :questions,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['text'].blank? }
  
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }
  validates :code, presence: true, uniqueness: true, length: { is: 8 }

  before_validation :generate_code, on: :create
  
  scope :by_user, ->(user) { where(author_id: user.id) }

  def question_count
    questions.count
  end

  before_validation :set_questions_order
  
  private
  
  def generate_code
    return if code.present?
    
    loop do
      self.code = SecureRandom.alphanumeric(8).upcase
      break unless Quiz.exists?(code: self.code)
    end
  end
  
  def set_questions_order
    questions.each_with_index do |question, index|
      question.order_index = index + 1 if question.order_index.blank?
    end
  end
end
