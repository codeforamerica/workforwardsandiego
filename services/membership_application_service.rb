require 'pdf-forms'
require 'tempfile'

module WorkForwardNola
  class MembershipApplicationService
    PDF_PATH = 'public/ajcc_membership.pdf'.freeze

    def initialize(job_app, services)
      @job_app = job_app
      @form_data = {}
      @services = services
    end

    def get_filled_form
      @form_data['Email'] = @job_app.email if @job_app.email
      @form_data['Last name Family name  surname'] = @job_app.last_name if @job_app.last_name
      @form_data['First name Given name'] = @job_app.first_name if @job_app.first_name
      @form_data['Gender identity'] = @job_app.gender if @job_app.gender
      @form_data['Primary phone'] = @job_app.phone if @job_app.phone
      @form_data[@job_app.selective_service] = 'Yes' if @job_app.selective_service
      @form_data[@job_app.work_authorization] = 'Yes' if @job_app.work_authorization
      @form_data[@job_app.education] = 'Yes' if @job_app.education
      @form_data[@job_app.current_employment_status] = 'Yes' if @job_app.current_employment_status
      @form_data[@job_app.unemployment_insurance] = 'Yes' if @job_app.unemployment_insurance
      @form_data['Total number of individuals living in your household'] = @job_app.household_size if @job_app.household_size
      @form_data[@job_app.termination_notice] = 'Yes' if @job_app.termination_notice
      @form_data['What is your desired job'] = @job_app.desired_job if @job_app.desired_job
      @form_data['Date'] = Date.today
      @form_data['Total income you earned within last 6 months'] = @job_app.six_month_income.to_s('F') if @job_app.six_month_income
      @form_data['Layoff transition support'] = 'Yes' if @job_app.recently_laid_off
      @form_data["Veterans' resources"] = 'Yes' if @job_app.veteran
      @form_data[@job_app.current_school] = 'Yes' if @job_app.current_school

      if ['employed', 'employed with notice of military separation', 'employed with notice of termination'].include?(@job_app.current_employment_status)
        @form_data['Employer'] = @job_app.employer
        @form_data['Hourly wage'] = @job_app.wage.to_s('F')
        @form_data['Hours worked'] = @job_app.hours_worked.to_s('F')
      end

      if @job_app.current_employment_status == 'not employed'
        @form_data['Last employer'] = @job_app.employer
        @form_data['Hourly wage_2'] = @job_app.wage.to_s('F')
        @form_data['Date last worked'] = @job_app.date_last_worked
      end

      fill_boolean_field(@job_app.farm_work, 'Yes', 'No')
      fill_boolean_field(@job_app.looking_for_work, 'are you currently looking for work: Yes', 'are you currently looking for work: No')
      fill_boolean_field(@job_app.military_caregiver, 'yes1', 'no1')
      fill_boolean_field(@job_app.military, 'yes3', 'no3')
      fill_boolean_field(@job_app.military_dependent, 'yes4', 'no4')
      fill_boolean_field(@job_app.tanf, 'yes5', 'no5')
      fill_boolean_field(@job_app.snap, 'yes6', 'no6')
      fill_boolean_field(@job_app.general_assistance, 'yes7', 'no7')
      fill_boolean_field(@job_app.refugee_cash_assistance, 'yes8', 'no8')

      @form_data['Expungement'] = 'Yes' if @job_app.expungement
      @form_data['Support of case manager'] = 'Yes' if @job_app.case_manager

      if @services
        @services.each do |val|
          @form_data[val] = 'Yes'
        end
      end

      if @job_app.other
        @form_data['Other (Please explain)'] = 'Yes'

        length = @job_app.other.length
        @form_data['Other Please explain 1'] = @job_app.other[0..(length/2)]
        @form_data['Other Please explain 2'] = @job_app.other[(length/2 + 1)..length]
      end

      filename = "/tmp/#{SecureRandom.urlsafe_base64}.pdf"

      PdfForms.new('pdftk').fill_form PDF_PATH, filename, @form_data

      filename
    end

    private

    def fill_boolean_field(param, yes_key, no_key)
      unless param.nil?
        param ? @form_data[yes_key] = 'Yes' : @form_data[no_key] = 'Yes'
      end
    end
  end
end
