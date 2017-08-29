class UsersController < ApplicationController
  before_action :authorise_user!, only: [:link, :show]

  def show
    @etsy_user = Etsy.myself(@current_user.oauth_token, @current_user.oauth_secret)
    @shop = @etsy_user.shop
    @receipts = Etsy::Receipt.find_all_by_shop_id(@shop.id, { :access_token => @current_user.oauth_token, :access_secret => @current_user.oauth_secret })
  end

  def new
    @user = User.new
  end

  def create
    user = User.find_global(:email, user_params[:email]).first

    @user = User.new
    @user.email = user_params[:email]
    @user.password = user_params[:password]

    unique_email = EmailValidator.not_unique(@user, user)
    valid_email = EmailValidator.validate_email(@user, user_params[:email])
    valid_password = PasswordValidator.validate_passwords(@user, user_params[:password], user_params[:password_confirmation])

    if valid_password && valid_email && @user.save
      session[:user_id] = @user.id
      redirect_to :link_account
    else
      render :new
    end
  end

  def link
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
