require "rails_helper"

describe Officing::Residence do
  let!(:geozone)  { create(:geozone, census_code: "01") }
  let(:residence) { build(:officing_residence, document_number: "12345678Z") }

  describe "validations" do
    it "is valid" do
      expect(residence).to be_valid
    end

    it "is not valid without a document number" do
      residence.document_number = nil
      expect(residence).not_to be_valid
    end

    it "is not valid without a document type" do
      residence.document_type = nil
      expect(residence).not_to be_valid
    end

    it "is not valid without a year of birth" do
      residence.year_of_birth = nil
      expect(residence).not_to be_valid
    end

    it "is valid without a date of birth" do
      residence.date_of_birth = nil
      expect(residence).to be_valid
    end

    it "is valid without a postal code" do
      residence.postal_code = nil
      expect(residence).to be_valid
    end

    describe "custom validations" do
      let(:custom_residence) do
        build(:officing_residence,
              document_number: "12345678Z",
              date_of_birth: "01/01/1980",
              postal_code: "15688")
      end

      before do
        configure_remote_census_api(date_of_birth_path: "some.value", postal_code_path: "some.value")
      end

      it "is valid" do
        expect(custom_residence).to be_valid
      end

      it "is not valid without a document number" do
        custom_residence.document_number = nil
        expect(custom_residence).not_to be_valid
      end

      it "is not valid without a document type" do
        custom_residence.document_type = nil
        expect(custom_residence).not_to be_valid
      end

      it "is valid without a year of birth when date_of_birth is present" do
        custom_residence.year_of_birth = nil

        expect(custom_residence).to be_valid
      end

      it "is not valid without a date of birth" do
        custom_residence.date_of_birth = nil

        expect(custom_residence).not_to be_valid
      end

      it "is not valid without a postal_code" do
        custom_residence.postal_code = nil

        expect(custom_residence).not_to be_valid
      end

      describe "dates" do
        it "is valid with a valid date of birth" do
          custom_residence = Officing::Residence.new("date_of_birth(3i)" => "1",
                                                 "date_of_birth(2i)" => "1",
                                                 "date_of_birth(1i)" => "1980")

          expect(custom_residence.errors[:date_of_birth]).to be_empty
        end

        it "is not valid without a date of birth" do
          custom_residence = Officing::Residence.new("date_of_birth(3i)" => "",
                                                 "date_of_birth(2i)" => "",
                                                 "date_of_birth(1i)" => "")
          expect(custom_residence).not_to be_valid
          expect(custom_residence.errors[:date_of_birth]).to include("can't be blank")
        end
      end

      it "stores failed census calls and set postal_code attribute" do
        Setting["remote_census.request.date_of_birth"] = ""

        residence = build(:officing_residence,
                          :invalid,
                          document_number: "87654321Z",
                          postal_code: "00001")
        residence.save

        expect(FailedCensusCall.count).to eq(1)
        expect(FailedCensusCall.first).to have_attributes(
          user_id:         residence.user.id,
          poll_officer_id: residence.officer.id,
          document_number: "87654321Z",
          document_type:   "1",
          date_of_birth: nil,
          postal_code: "00001",
          year_of_birth: Time.current.year
        )
      end
    end

    describe "allowed age" do
      it "is not valid if user is under allowed age" do
        skip "CensusApi is not configured on this fork"
        allow_any_instance_of(Officing::Residence).to receive(:response_date_of_birth).and_return(15.years.ago)
        expect(residence).not_to be_valid
        expect(residence.errors[:year_of_birth]).to include("You don't have the required age to participate")
      end

      it "is valid if user is above allowed age" do
        skip "CensusApi is not configured on this fork"
        allow_any_instance_of(Officing::Residence).to receive(:response_date_of_birth).and_return(16.years.ago)
        expect(residence).to be_valid
        expect(residence.errors[:year_of_birth]).to be_empty
      end

      describe "when using remote census api" do
        before { configure_remote_census_api(date_of_birth_path: "some.value") }

        it "is not valid if user is under allowed age" do
          allow_any_instance_of(Officing::Residence).to receive(:date_of_birth).and_return(15.years.ago)
          expect(residence).not_to be_valid
          expect(residence.errors[:year_of_birth]).to include("You don't have the required age to participate")
        end

        it "is valid if user is above allowed age" do
          allow_any_instance_of(Officing::Residence).to receive(:date_of_birth).and_return(16.years.ago)
          expect(residence).to be_valid
          expect(residence.errors[:year_of_birth]).to be_empty
        end
      end
    end
  end

  describe "new" do
    it "upcases document number" do
      residence = Officing::Residence.new(document_number: "x1234567z")
      expect(residence.document_number).to eq("X1234567Z")
    end

    it "removes all characters except numbers and letters" do
      residence = Officing::Residence.new(document_number: " 12.345.678 - B")
      expect(residence.document_number).to eq("12345678B")
    end
  end

  describe "save" do
    it "stores document number, document type, geozone, date of birth and gender" do
      skip "CensusApi is not configured on this fork"

      residence.save!
      user = residence.user

      expect(user.document_number).to eq("12345678Z")
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(1980)
      expect(user.date_of_birth.month).to eq(12)
      expect(user.date_of_birth.day).to eq(31)
      expect(user.gender).to eq("male")
      expect(user.geozone).to eq(geozone)
    end

    it "stores document number, document type, geozone, date of birth and gender when using remote census" do
      geozone.update!(census_code: "1")
      residence.date_of_birth = "31/12/1980"
      configure_remote_census_api(date_of_birth_path: "some.value")

      residence.save!
      user = residence.user

      expect(user.document_number).to eq("12345678Z")
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(1980)
      expect(user.date_of_birth.month).to eq(12)
      expect(user.date_of_birth.day).to eq(31)
      expect(user.gender).to be_blank
      expect(user.geozone).to eq(geozone)
    end

    it "finds existing user and use demographic information" do
      geozone = create(:geozone)
      create(:user, document_number: "12345678Z",
                    document_type: "1",
                    date_of_birth: Date.new(1981, 11, 30),
                    gender: "female",
                    geozone: geozone)

      residence = build(:officing_residence,
                        document_number: "12345678Z",
                        document_type: "1")

      residence.save!
      user = residence.user

      expect(user.document_number).to eq("12345678Z")
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(1981)
      expect(user.date_of_birth.month).to eq(11)
      expect(user.date_of_birth.day).to eq(30)
      expect(user.gender).to eq("female")
      expect(user.geozone).to eq(geozone)
    end

    it "makes half-verified users fully verified" do
      skip "CensusApi is not configured on this fork"
      user = create(:user, residence_verified_at: Time.current, document_type: "1", document_number: "12345678Z")
      expect(user).to be_unverified
      residence = build(:officing_residence, document_number: "12345678Z", year_of_birth: 1980)
      expect(residence).to be_valid
      expect(user.reload).to be_unverified
      residence.save!
      expect(user.reload).to be_level_three_verified
    end

    it "makes half-verified users fully verified when using remote census api" do
      configure_remote_census_api
      user = create(:user, residence_verified_at: Time.current, document_type: "1", document_number: "12345678Z")
      expect(user).to be_unverified
      residence = build(:officing_residence, document_number: "12345678Z", year_of_birth: 1980)
      expect(residence).to be_valid
      expect(user.reload).to be_unverified
      residence.save!
      expect(user.reload).to be_level_three_verified
    end

    it "stores failed census calls" do
      skip "CensusApi is not configured on this fork"
      residence = build(:officing_residence, :invalid, document_number: "12345678Z")
      residence.save

      expect(FailedCensusCall.count).to eq(1)
      expect(FailedCensusCall.first).to have_attributes(
        user_id:         residence.user.id,
        poll_officer_id: residence.officer.id,
        document_number: "12345678Z",
        document_type:   "1",
        date_of_birth: nil,
        postal_code: nil,
        year_of_birth:   Time.current.year
      )
    end

    it "stores failed census calls when using remote census api" do
      residence = build(:officing_residence, :invalid, document_number: "87654321Z")
      residence.save

      expect(FailedCensusCall.count).to eq(1)
      expect(FailedCensusCall.first).to have_attributes(
        user_id:         residence.user.id,
        poll_officer_id: residence.officer.id,
        document_number: "87654321Z",
        document_type:   "1",
        date_of_birth: nil,
        postal_code: nil,
        year_of_birth:   Time.current.year
      )
    end
  end
end
