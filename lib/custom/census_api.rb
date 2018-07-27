require "savon"
require 'logger'

class CensusApi

    def call(document_number, date_of_birth)
        logger = Logger.new(STDOUT)
        response = nil
        get_document_number_variants(document_number).each do |variant|
            response = Response.new(get_response_body(variant, date_of_birth))
            logger.debug "response: #{response.inspect} code #{response.code}"
        return response if response.valid?
        end
        response
    end

    def get_document_number_variants(document_number)
        # Delete all non-alphanumerics
        document_number = document_number.to_s.gsub(/[^0-9A-Za-z]/i, '')
        variants = []

        document_number, letter = split_letter_from(document_number)
        number_variants = get_number_variants_with_leading_zeroes_from(document_number)
        letter_variants = get_letter_variants(number_variants, letter)

        variants += number_variants
        variants += letter_variants

        variants
    end

    class Response
        def initialize(body)
            @body = body
        end

        def valid?
            data[:esta_empadronado_result] == '1'
        end
    
        def code
            data[:esta_empadronado_result]
        end

        def data
            @data ||= begin
                        if @body[:confirma_padron_response]
                            @body[:confirma_padron_response]
                        end
                      end
        end
    end

    private

    def get_response_body(document_number, date_of_birth)
        logger = Logger.new(STDOUT)

    if end_point_available?
           r = request(document_number, date_of_birth)
           logger.debug "request #{r.inspect} "
           @rebody= client.call(:confirma_padron, message: request(document_number, date_of_birth)).body
           logger.debug "response-api #{@rebody.inspect} "
        @rebody 
    else
            stubbed_response_body
        end
    end

    def client
        #census_api_end_point = Rails.application.secrets.census_api_end_point
        @client = Savon.client(wsdl: Rails.application.secrets.census_api_end_point)
    end

    def transform_date_of_birth(date_of_birth)
        date_api = date_of_birth.strftime('%d%m%Y')
        #logger = Logger.new(STDOUT)
        #logger.debug "fecha api #{date_api.inspect} "
        date_api
    end

    def request(document_number, date_of_birth)
        {
            :confirma_padron_entrada => {
                :dni => document_id,
                "tns:data_nac" => dateofbirth,
                :appkey => Rails.application.secrets.census_api_institution_code 
            }
        }
    end

    def end_point_available?
        true
        # Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
    end

    def stubbed_response_body
=begin       
        {
            :get_ciudadano_response => {
                :apellido1=>nil, 
                :apellido2=>nil, 
                :codigo_postal=>nil, 
                :fecha_nacimiento=>nil, 
                :nif=>nil, 
                :nombre=>nil, 
                :sexo=>nil
            }, 
            :@xmlns=>"http://schemas.xmlsoap.org/wsdl/"
        }
=end
        {
            :confirma_padron_response => {
                :return => {
                    :codigo_resposta => nil, 
                    :empadroado => nil, 
                    :distrito => nil, 
                    :seccion => nil, 
                    :"@xsi:type" => "tns:confirma_padron_resposta"
                }, 
                :"@xmlns:ns1" => "urn:orzamentos_ws"
            }
        }

    end

    def split_letter_from(document_number)
        letter = document_number.last
        if letter[/[A-Za-z]/] == letter
            document_number = document_number[0..-2]
        else
            letter = nil
        end
        return document_number, letter
    end

    # if the number has less digits than it should, pad with zeros to the left and add each variant to the list
    # For example, if the initial document_number is 1234, and digits=8, the result is
    # ['1234', '01234', '001234', '0001234']
    def get_number_variants_with_leading_zeroes_from(document_number, digits=8)
        document_number = document_number.to_s.last(digits) # Keep only the last x digits
        document_number = document_number.gsub(/^0+/, '')   # Removes leading zeros

        variants = []
        variants << document_number unless document_number.blank?
        while document_number.size < digits
            document_number = "0#{document_number}"
            variants << document_number
        end
        variants
    end

    # Generates uppercase and lowercase variants of a series of numbers, if the letter is present
    # If number_variants == ['1234', '01234'] & letter == 'A', the result is
    # ['1234a', '1234A', '01234a', '01234A']
    def get_letter_variants(number_variants, letter)
        variants = []
        if letter.present? then
            number_variants.each do |number|
                variants << number + letter.downcase << number + letter.upcase
            end
        end
        variants
    end
end
