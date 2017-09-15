class DashboardController < ApplicationController
  before_action :authorise_user!

  def index
    @etsy_user = Etsy.myself(@current_user.oauth_token, @current_user.oauth_secret)
    @shop = @etsy_user.shop
    @receipts = Etsy::Receipt.find_all_by_shop_id(@shop.id, { :access_token => @current_user.oauth_token, :access_secret => @current_user.oauth_secret })
  end
end
