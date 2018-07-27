require_dependency Rails.root.join('app', 'models', 'verification', 'residence').to_s

class Verification::Residence

  validate :postal_code_in_santiago
  validate :residence_in_santiago

  def postal_code_in_santiago
    errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
  end

  def residence_in_santiago
    return if errors.any?

    unless residency_valid?
      errors.add(:residence_in_santiago, false)
      store_failed_attempt
      #Lock.increase_tries(user)
    end
  end

  def district_code
    postal_code
  end

  def gender
    ""
  end

  private

    def retrieve_census_data
      @census_data = CensusCaller.new.call(document_number, date_of_birth)
    end

    def valid_postal_code?
      postal_code =~ /^157/#["15701", "15702", "15703", "15704", "15705", "15706", "15707", "15899"].include?(postal_code)
    end

    def residency_valid?
      @census_data.valid?
    end

end

