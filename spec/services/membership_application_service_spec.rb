require 'rspec'
require './services/membership_application_service'
require 'bigdecimal'
require 'date'

describe WorkForwardNola::MembershipApplicationService do
  describe '#get_filled_form' do
    let(:pdftk) { double() }

    before do
      allow(PdfForms).to receive(:new).with('pdftk').and_return(pdftk)
      allow(pdftk).to receive(:fill_form)
    end

    subject { described_class.new(job_app, services).get_filled_form }

    context 'some provided fields' do
      let(:expected_form_data) do
        {
            'Email' => 'some_email',
            'Last name Family name  surname' => 'some_last_name',
            'First name Given name' => 'some_first_name',
            'Gender identity' => 'some_gender',
            'Primary phone' => 'some_phone',
            'some_selective_service' => 'Yes',
            'some_work_authorization' => 'Yes',
            'some_education' => 'Yes',
            'employed' => 'Yes',
            'some_unemployment_insurance' => 'Yes',
            'Total number of individuals living in your household' => 5,
            'Total income you earned within last 6 months' => '3233.54',
            'some_termination_notice' => 'Yes',
            'What is your desired job' => 'some_desired_job',
            'Date' => Date.today,
            'Layoff transition support' => 'Yes',
            'some_current_school' => 'Yes',
            'Employer' => 'some_employer',
            'Hourly wage' => '4.5',
            'Hours worked' => '40.0',
            'Yes' => 'Yes',
            'are you currently looking for work: No' => 'Yes',
            'yes1' => 'Yes',
            'no3' => 'Yes',
            'yes4' => 'Yes',
            'no5' => 'Yes',
            'yes6' => 'Yes',
            'no7' => 'Yes',
            'yes8' => 'Yes',
            'Support of case manager' => 'Yes',
            'Service 1' => 'Yes',
            'Service 2' => 'Yes',
            'Other (Please explain)' => 'Yes',
            'Other Please explain 1' => 'Blahb',
            'Other Please explain 2' => 'lah',
        }
      end
      let(:services) { ['Service 1', 'Service 2'] }
      let(:job_app) do
        double(
            email: 'some_email',
            last_name: 'some_last_name',
            first_name: 'some_first_name',
            gender: 'some_gender',
            phone: 'some_phone',
            selective_service: 'some_selective_service',
            recently_laid_off: true,
            veteran: false,
            work_authorization: 'some_work_authorization',
            education: 'some_education',
            current_school: 'some_current_school',
            current_employment_status: 'employed',
            unemployment_insurance: 'some_unemployment_insurance',
            household_size: 5,
            six_month_income: BigDecimal.new('3233.54'),
            employer: 'some_employer',
            wage: BigDecimal.new('4.50'),
            hours_worked: BigDecimal.new('40'),
            date_last_worked: 'some_date_last_worked',
            farm_work: true,
            termination_notice: 'some_termination_notice',
            looking_for_work: false,
            desired_job: 'some_desired_job',
            military_caregiver: true,
            military: false,
            military_dependent: true,
            tanf: false,
            snap: true,
            general_assistance: false,
            refugee_cash_assistance: true,
            expungement: false,
            case_manager: true,
            other: 'Blahblah'
        )
      end

      it 'should tell pdftk to fill the form' do
        filename = subject

        expect(pdftk).to have_received(:fill_form).with(
            'public/ajcc_membership.pdf',
            filename,
            hash_including(expected_form_data)
        )
      end
    end

    context 'no provided fields' do
      let(:expected_form_data) do
        {'Date' => Date.today}
      end
      let(:services) { nil }
      let(:job_app) do
        double(
            email: nil,
            last_name: nil,
            first_name: nil,
            gender: nil,
            phone: nil,
            selective_service: nil,
            recently_laid_off: nil,
            veteran: nil,
            work_authorization: nil,
            education: nil,
            current_school: nil,
            current_employment_status: nil,
            unemployment_insurance: nil,
            household_size: nil,
            six_month_income: nil,
            employer: nil,
            wage: nil,
            hours_worked: nil,
            date_last_worked: nil,
            farm_work: nil,
            termination_notice: nil,
            looking_for_work: nil,
            desired_job: nil,
            military_caregiver: nil,
            military: nil,
            military_dependent: nil,
            tanf: nil,
            snap: nil,
            general_assistance: nil,
            refugee_cash_assistance: nil,
            expungement: nil,
            case_manager: nil,
            other: nil,
        )
      end

      it 'should return a blank form' do
        filename = subject

        expect(pdftk).to have_received(:fill_form).with(
            'public/ajcc_membership.pdf',
            filename,
            hash_including(expected_form_data)
        )
      end
    end
  end
end
