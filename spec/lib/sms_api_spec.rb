require "rails_helper"
require "savon/mock/spec_helper"

describe SMSApi do
  let(:api) { SMSApi.new }

  context "#sms_deliver" do
    include Savon::SpecHelper

    before do
      endpoint = "https://www.mensajerianegocios.movistar.es/MiInterfazSImplificado.wsdl"
      allow(Rails.application.secrets).to receive(:sms_end_point).and_return(endpoint)
      savon.mock!
    end

    after do
      savon.unmock!
    end

    it "returns true when web service response is success" do
      success = File.read("spec/fixtures/files/sms_api/success.xml")
      savon.expects(:sms_text_submit).with(message: :any).returns(success)

      response = api.sms_deliver("666777888", "AAAA")

      expect(response).to be_truthy
    end

    it "returns false when web service response is error" do
      error = File.read("spec/fixtures/files/sms_api/error.xml")
      savon.expects(:sms_text_submit).with(message: :any).returns(error)

      response = api.sms_deliver("", "AAAA")

      expect(response).to be_falsey
    end
  end
end
