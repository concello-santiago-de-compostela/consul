class CensusCaller

  def call(document_number, date_of_birth)
    response = CensusApi.new.call(document_number, date_of_birth)
    #response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response
  end
end
