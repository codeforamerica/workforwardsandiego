require 'pdf-forms'
require 'tempfile'

module WorkForwardNola
  class MembershipApplicationService
    PDF_PATH = 'public/ajcc_membership.pdf'.freeze

    def initialize(params)
      @params = params
    end

    def get_filled_form
      form_data = {
          :Email => @params[:email],
          :'Last name Family name  surname' => @params[:last_name],
          :'First name Given name' => @params[:first_name],
          :'Gender identity' => @params[:gender],
          :'Primary phone' => @params[:phone],
          :'What is your desired job' => @params[:desired_job],
          :'Total number of individuals living in your household' => @params[:household_size],
          :'Total income you earned within last 6 months' => @params[:income]
      }

      form_data[@params[:selective_service]] = 'Yes'
      form_data[@params[:work_authorization]] = 'Yes'
      form_data[@params[:education]] = 'Yes'
      form_data[@params[:current_employment_status]] = 'Yes'
      form_data[@params[:unemployment_insurance]] = 'Yes'
      form_data[@params[:farm_work]] = 'Yes'
      form_data[@params[:termination_notice]] = 'Yes'
      form_data[@params[:looking_for_work]] = 'Yes'
      form_data[@params[:military_caregiver]] = 'Yes'
      form_data[@params[:military]] = 'Yes'
      form_data[@params[:military_dependent]] = 'Yes'
      form_data[@params[:tanf]] = 'Yes'
      form_data[@params[:snap]] = 'Yes'
      form_data[@params[:general_assistance]] = 'Yes'
      form_data[@params[:refugee_cash_assistance]] = 'Yes'
      form_data[@params[:current_school]] = 'Yes' if @params[:current_school] != 'no'

      if @params[:recently_laid_off] == 'true'
        form_data['Layoff transition support'] = 'Yes'
      end

      if @params[:veteran] == 'true'
        form_data["Veterans' resources"] = 'Yes'
        end

      if @params[:expungement] == 'true'
        form_data['Expungement'] = 'Yes'
        end

      if @params[:case_manager] == 'true'
        form_data['Support of case manager'] = 'Yes'
      end

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

      form_data['Date'] = Date.today

      job_app = JobApp.new(
          email: @params[:email],
          last_name: @params[:last_name],
          first_name: @params[:first_name],
          phone: @params[:phone]
      )

      if @params[:services]
        @params[:services].each do |val|
          form_data[val] = 'Yes'
        end

        job_app.set(services: @params[:services])
      end

      if @params[:other_services]
        form_data['Other (Please explain)'] = 'Yes'

        length = @params[:other_services].length
        form_data['Other Please explain 1'] = @params[:other_services][0..(length/2)]
        form_data['Other Please explain 2'] = @params[:other_services][(length/2 + 1)..length]

        job_app.set(other: @params[:other_services])
      end

      job_app.save

      filename = "/tmp/#{SecureRandom.urlsafe_base64}.pdf"

      PdfForms.new('pdftk').fill_form PDF_PATH, filename, form_data

      filename
    end
  end
end
