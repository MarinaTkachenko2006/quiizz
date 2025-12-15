class SessionsController < ApplicationController
  def new
    flash.delete(:alert) if request.get?
  end

  def create
    email = params[:email]&.strip&.downcase
    password = params[:password]

    if email.blank? || password.blank?
      flash.now[:alert] = "Заполните все поля"
      render :new, status: :unprocessable_entity
      return
    end

    user = User.find_by(email: email)

    unless user
      flash.now[:alert] = "Пользователь не найден"
      render :new, status: :unprocessable_entity
      return
    end
    
    unless user.authenticate(password)
      flash.now[:alert] = "Неверный пароль"
      render :new, status: :unprocessable_entity
      return
    end


    
    session[:user_id] = user.id
    redirect_to root_path, notice: "Вход успешен"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Вы вышли"
  end
end