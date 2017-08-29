class PasswordValidator < ActiveModel::EachValidator
  REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$/
  REGEX_MISMATCH_MESSAGE = 'must be at least 8 characters long and contain 1 lowercase letter, 1 uppercase letter and 1 number.'
  PASSWORD_MISMATCH_MESSAGE = 'must match password.'

  def validate_each(record, attribute, value)
    unless value =~ PasswordValidator::REGEX
      record.errors[attribute] << (options[:message] || PasswordValidator::REGEX_MISMATCH)
    end
  end

  def self.validate_passwords(object, password, password_confirmation)
    password_regex_match = (password =~ PasswordValidator::REGEX)
    password_match = (password == password_confirmation)

    object.errors[:password] << PasswordValidator::REGEX_MISMATCH_MESSAGE unless password_regex_match
    object.errors[:password_confirmation] << PasswordValidator::PASSWORD_MISMATCH_MESSAGE unless password_match

    (password_regex_match && password_match)
  end
end