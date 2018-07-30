require_dependency Rails.root.join('app', 'models', 'concerns', 'verification').to_s

module Verification
  extend ActiveSupport::Concern

  def sms_verified?
    true
  end

  def verification_letter_sent?
    true 
  end

  def verification_sms_sent?
    true
  end

end