require 'etsy'

Etsy.api_key = ENV['ETSY_API_KEY']
Etsy.api_secret = ENV['ETSY_API_SECRET']
Etsy.silent_errors = false
Etsy.permission_scopes = %w(transactions_r shops_rw)

unless Rails.env.test?
  countries_hash = {}

  countries = Etsy::Country.find_all
  countries.each do |country|
    countries_hash[country.id] = country.name
  end
else
  {}
end

ETSY_COUNTRIES = countries_hash