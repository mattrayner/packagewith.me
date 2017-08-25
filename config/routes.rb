Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'brochure#index'

  # Etsy account linking
  scope '/etsy' do
    get '/login',     to: 'auth#login',     as: 'auth_login'
    get '/authorise', to: 'auth#authorise', as: 'auth_authorise'
  end

  # User session management
  get       '/sign_in',   to: 'sessions#new',     as: 'log_in'
  get       '/sign_out',  to: 'sessions#delete',  as: 'log_out'
  resources :sessions,    only: :create

  # User signup
  scope   '/sign_up' do
    get '/',              to: 'users#new',  as: 'sign_up'
    get '/link_account',  to: 'users#link', as: 'link_account'
  end

  resources :users
end
