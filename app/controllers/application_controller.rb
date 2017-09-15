class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :current_user

  private

  def current_user
    if session[:user_id]
      begin
        @current_user ||= User.find(session[:user_id])
      rescue OceanDynamo::RecordNotFound => e
        puts e
        session[:user_id] = nil
      end
    end

  end

  def authorise_user!
    return true if current_user

    redirect_to :log_in, alert: 'You must be logged in to see this.'
  end
end
