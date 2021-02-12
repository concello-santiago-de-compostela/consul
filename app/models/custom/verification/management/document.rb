require_dependency Rails.root.join("app", "models", "verification", "management", "document").to_s

class Verification::Management::Document
  alias_method :consul_under_age?, :under_age?

  def under_age?(*)
    consul_under_age?(OpenStruct.new(date_of_birth: date_of_birth))
  end
end
