class QuizSession < ApplicationRecord
    belongs_to :quiz
    belongs_to :user

    validates :quiz_id, uniqueness: { scope: :user_id }
    validates :score, numericality: { greater_than_or_equal_to: 0 }
    validates :number_correct_answers, numericality: { greater_than_or_equal_to: 0 }

    scope :completed, -> { where(is_completed: true) }
    scope :by_quiz, ->(quiz_id) { where(quiz_id: quiz_id) }

    def accuracy
        return 0 if quiz.questions.count.zero? (correct_answers.to_f / quiz.questions.count * 100).round(1)
    end
    
end


