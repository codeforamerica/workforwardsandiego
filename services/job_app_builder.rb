module WorkForwardNola
  class JobAppBuilder
    def initialize(params)
      @params = params
    end

    def build
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
    end
  end
end

