require_dependency Rails.root.join("app", "models", "verification", "residence").to_s

class Verification::Residence
  POSTAL_CODES = %w[15688 15701 15702 15703 15704 15705 15706 15707 15820 15884 15890 15891 15892 15893 15896
    15897 15898 15899].freeze

  validate :local_postal_code
  validate :local_residence

  def local_postal_code
    errors.add(:postal_code, I18n.t("verification.residence.new.error_not_allowed_postal_code")) unless valid_postal_code?
  end

  def local_residence
    return if errors.any?

    unless residency_valid?
      errors.add(:local_residence, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  private

    def valid_postal_code?
      POSTAL_CODES.include? postal_code
    end
end
