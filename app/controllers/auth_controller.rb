class AuthController < ApplicationController
  before_action :authorise_user!

  def login
    Etsy.callback_url = url_for(:auth_authorise)

    begin
      request_token = Etsy.request_token
    rescue Errno::ECONNRESET => e
      logger.error(e)
      return redirect_to :link_account, alert: 'There was an issue connecting to Etsy. Please try again later.'
    rescue SocketError => e
      logger.error(e)
      return redirect_to :link_account, alert: 'There was an issue connecting to Etsy. Please try again later.'
    end

    session[:request_token]  = request_token.token
    session[:request_secret] = request_token.secret

    redirect_to Etsy.verification_url
  end

  def authorise
    begin
      access_token = Etsy.access_token(
        session[:request_token],
        session[:request_secret],
        params[:oauth_verifier]
      )
    rescue
      logger.warn 'Unable to get access_token - redirecting to account link'
      return redirect_to :link_account, alert: 'There was an issue linking to your Etsy account. Please try again.'
    end

    @current_user.oauth_token = access_token.token
    @current_user.oauth_secret = access_token.secret

    if @current_user.save
      user = Etsy.myself(@current_user.oauth_token, @current_user.oauth_secret)
      shop = user.shop

      if shop.nil?
        redirect_to :root, notice: "We couldn't find a shop linked to your account." if shop.nil?
      else
        redirect_to user_path(@current_user.id), notice: 'Account successfully linked'
      end
    else
      redirect_to :link_account, alert: 'Where was an issue updating your account. Please try again later.'
    end
  end

end
