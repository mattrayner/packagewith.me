class EmailValidator < ActiveModel::EachValidator
  REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  REGEX_MISMATCH_MESSAGE = 'is not an email.'
  ALREADY_EXISTS_MESSAGE = 'already exists.'

  def validate_each(record, attribute, value)
    unless value =~ EmailValidator::REGEX
      record.errors[attribute] << (options[:message] || EmailValidator::REGEX_MISMATCH_MESSAGE)
    end
  end

  def self.validate_email(object, email)
    email_regex_match = (email =~ EmailValidator::REGEX)

    object.errors[:email] << EmailValidator::REGEX_MISMATCH_MESSAGE unless email_regex_match

    email_regex_match
  end

  def self.not_unique(object, user)
    object.errors[:email] << EmailValidator::ALREADY_EXISTS_MESSAGE if user

    user
  end
end