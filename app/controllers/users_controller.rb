class UsersController < ApplicationController
  # skip_before_action :require_login, only: [:new, :create]
  
  before_action :require_login, except: [:new, :create]
  before_action :set_user, except: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'Регистрация успешна'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user ||= current_user

    unless @user
        flash[:alert] = "Вы не авторизованы. Пожалуйста, войдите в систему."
        redirect_to login_path
        return
    end

  end

  def edit
  end

  def update
    if @user.update(user_update_params)
        redirect_to profile_path, notice: 'Профиль обновлён'
    else
        render :edit, status: :unprocessable_entity
    end
  end

  def change_password
  end

  def update_password
    if @user.authenticate(params[:current_password])
      if @user.update(password: params[:new_password], password_confirmation: params[:password_confirmation])
        redirect_to profile_path, notice: 'Пароль успешно изменен!'
      else
        flash.now[:alert] = 'Ошибка при изменении пароля'
        render :change_password, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = 'Текущий пароль неверен'
      render :change_password, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:nickname, :email, :password, :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:nickname, :email)
  end
end