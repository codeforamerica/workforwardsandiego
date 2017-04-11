module WorkForwardNola
  class IntakeFormService
    def initialize(host:, job_app_id:)
      @host = host
      @job_app_id = job_app_id
    end

    def intake_form
      intake_url = "http://#{@host}/intake/#{@job_app_id}"

      "/tmp/#{SecureRandom.urlsafe_base64}.pdf".tap do |filename|
        PDFKit.new(intake_url, dpi: 250, viewport_size: '1700x2200').to_file(filename)
      end
    end
  end
end
