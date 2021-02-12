require "open-uri"
class SMSApi
  attr_accessor :client

  def initialize
    @client = Savon.client(wsdl: url, convert_request_keys_to: :camelcase)
  end

  def url
    return "" unless end_point_available?

    open(Rails.application.secrets.sms_end_point).base_uri.to_s
  end

  def authorization
    Base64.encode64("#{Rails.application.secrets.sms_username}:#{Rails.application.secrets.sms_password}")
  end

  def sms_deliver(phone, code)
    return stubbed_response unless end_point_available?

    response = client.call(:sms_text_submit, message: request(phone, code))
    success?(response)
  end

  def request(phone, code)
    {
      authorization: authorization,
      delivery_report: "All",
      recipients: { to: phone },
      sender: Rails.application.secrets.sms_sender,
      SMSText: I18n.t("sms_api.message", code: code),
      version: "1.0"
    }
  end

  def success?(response)
    response.body[:submit_res][:status][:status_text] == "Success"
  end

  def end_point_available?
    Rails.application.secrets.sms_end_point.present?
  end

  def stubbed_response
    {
      respuesta_sms: {
        identificador_mensaje: "1234567",
        fecha_respuesta: "Thu, 20 Aug 2015 16:28:05 +0200",
        respuesta_pasarela: {
          codigo_pasarela: "0000",
          descripcion_pasarela: "Operación ejecutada correctamente."
        },
        respuesta_servicio_externo: {
          codigo_respuesta: "1000",
          texto_respuesta: "Success"
        }
      }
    }
  end
end
