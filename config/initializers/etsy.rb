require 'etsy'

Etsy.api_key = ENV['ETSY_API_KEY']
Etsy.api_secret = ENV['ETSY_API_SECRET']
Etsy.silent_errors = false
Etsy.permission_scopes = %w(transactions_r shops_rw)