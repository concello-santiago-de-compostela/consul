require_dependency Rails.root.join("app", "models", "setting").to_s

class Setting
  class << self
    alias_method :consul_defaults, :defaults

    def defaults
      consul_defaults.merge({
        "facebook_handle": "concellosantiago",
        "remote_census.general.endpoint": Rails.application.secrets.census_api_end_point,
        "remote_census.request.method_name": "confirma_padron",
        "remote_census.request.structure": %Q({ "confirma_padron_entrada":
          {
            "dni": "null",
            "tns:data_nac": "null",
            "appkey": "#{Rails.application.secrets.census_api_institution_code}"
          }
        }),
        "remote_census.request.document_type": nil,
        "remote_census.request.document_number": "confirma_padron_entrada.dni",
        "remote_census.request.date_of_birth": "confirma_padron_entrada.tns:data_nac",
        "remote_census.request.postal_code": nil,
        "remote_census.response.date_of_birth": nil,
        "remote_census.response.postal_code": nil,
        "remote_census.response.district": "confirma_padron_response.return.distrito",
        "remote_census.response.gender": nil,
        "remote_census.response.name": nil,
        "remote_census.response.surname": nil,
        "remote_census.response.valid": "confirma_padron_response.return.empadroado",
        "twitter_handle": "pazoderaxoi",
        "youtube_handle": "channel/UCSrcC2UgDHIb80vVVRtvoDw"
      })
    end
  end
end
