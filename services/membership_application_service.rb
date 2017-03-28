require 'pdf-forms'
require 'tempfile'

module WorkForwardNola
  class MembershipApplicationService
    PDF_PATH = 'public/ajcc_membership.pdf'.freeze

    def initialize(params)
      @params = params
    end

    def get_filled_form
      JobApp.create(
          email: @params[:email],
          last_name: @params[:last_name],
          first_name: @params[:first_name],
          gender: @params[:gender],
          phone: @params[:phone],
          selective_service: @params[:selective_service],
          recently_laid_off: @params[:recently_laid_off],
          veteran: @params[:veteran],
          work_authorization: @params[:work_authorization],
          education: @params[:education],
          current_school: @params[:current_school],
          current_employment_status: @params[:current_employment_status],
          unemployment_insurance: @params[:unemployment_insurance],
          household_size: @params[:household_size],
          six_month_income: @params[:income],
          employer: @params[:employer],
          wage: @params[:wage],
          hours_worked: @params[:hours_worked],
          date_last_worked: @params[:date_last_worked],
          farm_work: @params[:farm_work],
          termination_notice: @params[:termination_notice],
          looking_for_work: @params[:looking_for_work],
          desired_job: @params[:desired_job],
          military_caregiver: @params[:military_caregiver],
          military: @params[:military],
          military_dependent: @params[:military_dependent],
          tanf: @params[:tanf],
          snap: @params[:snap],
          general_assistance: @params[:general_assistance],
          refugee_cash_assistance: @params[:refugee_cash_assistance],
          expungement: @params[:expungement],
          case_manager: @params[:case_manager],
          services: @params[:services],
          other: @params[:other_services]
      )

      form_data = {
          Email: @params[:email],
          'Last name Family name  surname': @params[:last_name],
          'First name Given name': @params[:first_name],
          'Gender identity': @params[:gender],
          'Primary phone': @params[:phone],
          @params[:selective_service] => 'Yes',
          @params[:work_authorization] => 'Yes',
          @params[:education] => 'Yes',
          @params[:current_employment_status] => 'Yes',
          @params[:unemployment_insurance] => 'Yes',
          'Total number of individuals living in your household': @params[:household_size],
          'Total income you earned within last 6 months': @params[:income],
          @params[:termination_notice] => 'Yes',
          'What is your desired job': @params[:desired_job],
          Date: Date.today
      }

      form_data['Layoff transition support'] = 'Yes' if @params[:recently_laid_off] == 'true'

      form_data["Veterans' resources"] = 'Yes' if @params[:veteran] == 'true'

      form_data[@params[:current_school]] = 'Yes' if @params[:current_school] != 'no'

      if ['employed', 'employed with notice of military separation', 'employed with notice of termination'].include? @params[:current_employment_status]
        form_data['Employer'] = @params[:employer]
        form_data['Hourly wage'] = @params[:wage]
        form_data['Hours worked'] = @params[:hours_worked]
      end

      if @params[:current_employment_status] == 'not employed'
        form_data['Last employer'] = @params[:employer]
        form_data['Hourly wage_2'] = @params[:wage]
        form_data['Date last worked'] = @params[:date_last_worked]
      end

      form_data['Yes'] = 'Yes' if @params[:farm_work] == 'true'
      form_data['No'] = 'Yes' if @params[:farm_work] == 'false'

      form_data['are you currently looking for work: Yes'] = 'Yes' if @params[:looking_for_work] == 'true'
      form_data['are you currently looking for work: No'] = 'Yes' if @params[:looking_for_work] == 'false'

      form_data['yes1'] = 'Yes' if @params[:military_caregiver] == 'true'
      form_data['no1'] = 'Yes' if @params[:military_caregiver] == 'false'

      form_data['yes3'] = 'Yes' if @params[:military] == 'true'
      form_data['no3'] = 'Yes' if @params[:military] == 'false'

      form_data['yes4'] = 'Yes' if @params[:military_dependent] == 'true'
      form_data['no4'] = 'Yes' if @params[:military_dependent] == 'false'

      form_data['yes5'] = 'Yes' if @params[:tanf] == 'true'
      form_data['no5'] = 'Yes' if @params[:tanf] == 'false'

      form_data['yes6'] = 'Yes' if @params[:snap] == 'true'
      form_data['no6'] = 'Yes' if @params[:snap] == 'false'

      form_data['yes7'] = 'Yes' if @params[:general_assistance] == 'true'
      form_data['no7'] = 'Yes' if @params[:general_assistance] == 'false'

      form_data['yes8'] = 'Yes' if @params[:refugee_cash_assistance] == 'true'
      form_data['no8'] = 'Yes' if @params[:refugee_cash_assistance] == 'false'

      form_data['Expungement'] = 'Yes' if @params[:expungement] == 'true'

      form_data['Support of case manager'] = 'Yes' if @params[:case_manager] == 'true'

      if @params[:services]
        @params[:services].each do |val|
          form_data[val] = 'Yes'
        end
      end

      if @params[:other_services]
        form_data['Other (Please explain)'] = 'Yes'

        length = @params[:other_services].length
        form_data['Other Please explain 1'] = @params[:other_services][0..(length/2)]
        form_data['Other Please explain 2'] = @params[:other_services][(length/2 + 1)..length]
      end

      filename = "/tmp/#{SecureRandom.urlsafe_base64}.pdf"

      PdfForms.new('pdftk').fill_form PDF_PATH, filename, form_data

      filename
    end
  end
end
