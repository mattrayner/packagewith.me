class User < OceanDynamo::Table
  include ActiveModel::Validations

  validates :email, presence: true, email: true

  dynamo_schema(:id, create: !Rails.env.production?) do
    attribute :email,         :string
    attribute :oauth_token,   :string,   default: nil
    attribute :oauth_secret,  :string,   default: nil
    attribute :last_login,    :datetime, default: nil
    attribute :password_hash, :string
    attribute :password_salt, :string

    global_secondary_index :email, projection: :all
  end

  def self.authenticate(email, password)
    user = User.find_global(:email, email).first
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def password=(unencrypted_password)
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(unencrypted_password, password_salt)
  end

  def enabled?

  end

end