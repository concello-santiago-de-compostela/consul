require_dependency Rails.root.join("app", "models", "officing", "residence").to_s

class Officing::Residence
  def response_date_of_birth
    parsed_date_of_birth
  end

  def parsed_date_of_birth
    if date_of_birth.is_a?(String)
      Date.parse(date_of_birth)
    elsif date_of_birth.present?
      date_of_birth
    elsif year_of_birth
      Date.ordinal(year_of_birth.to_i)
    end
   end

  def residency_valid?
    @census_api_response.valid?
  end
end
