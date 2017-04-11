require './services/membership_application_service'
require './services/intake_form_service'

module WorkForwardNola
  class PreparationMaterialsService
    def initialize(job_app, services, host)
      @job_app = job_app
      @services = services
      @host = host
    end

    def run
      "/tmp/#{SecureRandom.urlsafe_base64}.pdf".tap do |preparation_materials|
        PdfForms.new('pdftk').cat filled_form, intake_form, preparation_materials
      end
    end

    private

    def intake_form
      IntakeFormService.new(job_app_id: @job_app.id, host: @host).intake_form
    end

    def filled_form
      MembershipApplicationService.new(@job_app, @services).get_filled_form
    end
  end
end
