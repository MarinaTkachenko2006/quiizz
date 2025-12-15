class Quiz < ApplicationRecord
  self.primary_key = 'id'

  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  has_many :questions, dependent: :destroy
  has_many :quiz_sessions, dependent: :destroy
  has_many :participants, through: :quiz_sessions, source: :user

  accepts_nested_attributes_for :questions,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['text'].blank? }
  
  validates :title, 
    presence: { message: "Укажите название квиза" },
    length: { 
      maximum: 100, 
      message: "Название не должно превышать 100 символов" 
    }
  
  validates :description, 
    length: { 
      maximum: 500, 
      message: "Описание не должно превышать 500 символов" 
    }
  
  validates :author_id, 
    presence: { message: "Не указан автор" }


  before_create :generate_code
  
  scope :by_user, ->(user) { where(author_id: user.id) }

  def question_count
    questions.count
  end

  before_validation :set_questions_order
  
  private
  
  def generate_code   
    loop do
      self.id = SecureRandom.alphanumeric(8).upcase
      break unless Quiz.exists?(id: self.id)
    end
  end
  
  def set_questions_order
    questions.each_with_index do |question, index|
      question.order_index = index + 1 if question.order_index.blank?
    end
  end
end
