class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect_to user_path(user.id)
    else
      flash[:alert] = 'Invalid email or password'
      render :new
    end
  end

  def delete
    session[:user_id] = nil
    redirect_to :log_in, notice: 'Successfully logged out'
  end
end
