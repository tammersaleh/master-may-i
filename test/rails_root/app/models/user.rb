class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_password_field = false
    config.validate_email_field    = false
  end
end

