class QuizzesController < ApplicationController
  before_action :user_autorized
  before_action :set_quiz, only: [:show, :destroy]
  before_action :require_author, only: [:destroy]

  def index
    if params[:code].present?
      @quiz = Quiz.find_by(id: params[:code].upcase)
      if @quiz
        redirect_to quiz_path(@quiz)
        return
      else
        flash[:alert] = 'Квиз с таким кодом не найден'
      end
    end
    
    @quizzes = Quiz.order(created_at: :desc) || []
  end

  def show
    @quiz = Quiz.find(params[:id])
    @questions = @quiz.questions.includes(:answers).order(:order_index)
    
    @quiz_session = QuizSession.find_by(quiz_id: @quiz.id, user_id: current_user.id, is_completed: true)
    @already_completed = @quiz_session.present?
    
    if @already_completed
      @score = @quiz_session.score
      @correct_answers = @quiz_session.number_correct_answers
      @accuracy = @quiz_session.accuracy
    end
  end

  def new
    @quiz = Quiz.new
    @quiz.questions.build(order_index: 1,
                          reward: 10,
                          time_limit: 30)
    @quiz.questions.first.answers.build
  end

  def create
  @quiz = Quiz.new(quiz_params)
  @quiz.author_id = session[:user_id]

  if @quiz.save
    redirect_to root_path, notice: 'Квиз создан'
  else
    error_messages = []
    @quiz.errors.full_messages.each do |msg|
      error_messages << msg unless msg.include?("Questions")
    end
    
    @quiz.questions.each_with_index do |question, index|
      unless question.valid?
        question.errors.full_messages.each do |msg|
          error_messages << "Вопрос #{index + 1}: #{msg}"
        end
      end
    end
    error_messages.uniq!
    
    flash.now[:alert] = error_messages.join('. ')
    render :new, status: :unprocessable_entity
  end
end

  def destroy
    @quiz.destroy
    redirect_to quizzes_url, notice: 'Квиз удалён'
  end

  helper_method :is_author

  private

  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  def is_author
    session[:user_id] && @quiz && session[:user_id] == @quiz.author_id
  end

  def require_author
    unless session[:user_id] && @quiz && session[:user_id] == @quiz.author_id
      redirect_to root_path, alert: 'Только автор может менять квиз'
      return false
    end
    true
  end
  
  def user_autorized
    unless session[:user_id]
      redirect_to login_path, alert: 'Авторизуйтесь на странице'
      return false
    end
    true
  end

  def quiz_params
    params.require(:quiz).permit(
      :title,
      :description,
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
end