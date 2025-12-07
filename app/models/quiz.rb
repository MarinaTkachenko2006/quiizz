class Quiz < ApplicationRecord
  belongs_to :author, class_name: 'User'
  has_many :questions, dependent: :destroy

  accepts_nested_attributes_for :questions,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs['text'].blank? }
  
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }
  validates :is_public, inclusion: { in: [true, false] }

  scope :public_quizzes, -> { where(is_public: true) }
  scope :by_user, ->(user) { where(author_id: user.id) }

  def question_count
    questions.count
  end
end