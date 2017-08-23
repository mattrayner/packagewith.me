class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authorise_user!
    return true if current_user

    redirect_to :log_in, alert: 'You must be logged in to see this.'
  end
end
