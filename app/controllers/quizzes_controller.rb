class QuizzesController < ApplicationController
  before_action :user_autorized
  before_action :set_quiz, only: [:show, :destroy]
  before_action :is_author, only: [:destroy]

  def index
    @quizzes = Quiz.where(is_public: true).order(created_at: :desc)
  end

  def show
    @questions = @quiz.questions.includes(:answers).order(:order_index)
  end

  def new
    @quiz = Quiz.new
    @quiz.author_id = 0
    @quiz.questions.build(
      order_index: 1,
      reward: 10,
      time_limit: 30
    )
    @quiz.questions.first.answers.build
  end

  def create
    @quiz = Quiz.new(quiz_params)
    
    set_questions_order
    
    if @quiz.save
      redirect_to @quiz, notice: 'Quiz created'
    else
      flash.now[:alert] = 'Could not create the quiz'
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @quiz.destroy
    redirect_to quizzes_url, notice: 'Quiz deleted'
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  def is_author
    true
  end
  
  def user_autorized
    true
  end

  def quiz_params
    params.require(:quiz).permit(
      :title,
      :description,
      :is_public,
      questions_attributes: [
        :id,
        :text,
        :order_index,
        :reward,
        :time_limit,
        :_destroy,
        answers_attributes: [
          :id,
          :answer_text,
          :is_correct,
          :_destroy
        ]
      ]
    )
  end

  def set_questions_order
    @quiz.questions.each_with_index do |question, index|
      question.order_index = index + 1 if question.order_index.blank?
    end
  end
end