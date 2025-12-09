class MyQuizzesController < ApplicationController
  before_action :require_login

  def index
    @quizzes = current_user.quizzes.order(created_at: :desc)
  end
end