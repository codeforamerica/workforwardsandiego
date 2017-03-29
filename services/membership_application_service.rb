require 'pdf-forms'
require 'tempfile'

module WorkForwardNola
  class MembershipApplicationService
    PDF_PATH = 'public/ajcc_membership.pdf'.freeze

    def initialize(params)
      @params = params
      @form_data = {}
    end

    def get_filled_form
      job_app = JobApp.create(
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

      @form_data = {
          Email: job_app.email,
          'Last name Family name  surname': job_app.last_name,
          'First name Given name': job_app.first_name,
          'Gender identity': job_app.gender,
          'Primary phone': job_app.phone,
          job_app.selective_service => 'Yes',
          job_app.work_authorization => 'Yes',
          job_app.education => 'Yes',
          job_app.current_employment_status => 'Yes',
          job_app.unemployment_insurance => 'Yes',
          'Total number of individuals living in your household': job_app.household_size,
          'Total income you earned within last 6 months': job_app.six_month_income.to_s('F'),
          job_app.termination_notice => 'Yes',
          'What is your desired job': job_app.desired_job,
          Date: Date.today
      }

      @form_data['Layoff transition support'] = 'Yes' if job_app.recently_laid_off

      @form_data["Veterans' resources"] = 'Yes' if job_app.veteran

      @form_data[job_app.current_school] = 'Yes' if job_app.current_school != 'no'

      if ['employed', 'employed with notice of military separation', 'employed with notice of termination'].include?(job_app.current_employment_status)
        @form_data['Employer'] = job_app.employer
        @form_data['Hourly wage'] = job_app.wage
        @form_data['Hours worked'] = job_app.hours_worked
      end

      if @params[:current_employment_status] == 'not employed'
        @form_data['Last employer'] = job_app.employer
        @form_data['Hourly wage_2'] = job_app.wage
        @form_data['Date last worked'] = job_app.date_last_worked
      end

      fill_boolean_field(job_app.farm_work, 'Yes', 'No')
      fill_boolean_field(job_app.looking_for_work, 'are you currently looking for work: Yes', 'are you currently looking for work: No')
      fill_boolean_field(job_app.military_caregiver, 'yes1', 'no1')
      fill_boolean_field(job_app.military, 'yes3', 'no3')
      fill_boolean_field(job_app.military_dependent, 'yes4', 'no4')
      fill_boolean_field(job_app.tanf, 'yes5', 'no5')
      fill_boolean_field(job_app.snap, 'yes6', 'no6')
      fill_boolean_field(job_app.general_assistance, 'yes7', 'no7')
      fill_boolean_field(job_app.refugee_cash_assistance, 'yes8', 'no8')

      @form_data['Expungement'] = 'Yes' if job_app.expungement
      @form_data['Support of case manager'] = 'Yes' if job_app.case_manager

      if @params[:services]
        @params[:services].each do |val|
          @form_data[val] = 'Yes'
        end
      end

      if job_app.other
        @form_data['Other (Please explain)'] = 'Yes'

        length = job_app.other.length
        @form_data['Other Please explain 1'] = job_app.other[0..(length/2)]
        @form_data['Other Please explain 2'] = job_app.other[(length/2 + 1)..length]
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
