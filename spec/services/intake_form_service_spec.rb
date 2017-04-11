require 'pdfkit'
require './services/intake_form_service'

describe WorkForwardNola::IntakeFormService do
  describe '#intake_form' do
    subject { described_class.new(host: 'host:1234', job_app_id: 'some_id').intake_form }

    let(:kit) { double(:kit) }

    it 'returns a pdf of the intake form' do
      expect(PDFKit).to receive(:new)
                            .with('http://host:1234/intake/some_id', dpi: 250, viewport_size: '1700x2200')
                            .and_return(kit)

      expect(kit).to receive(:to_file).with('/tmp/random_filename.pdf')

      allow(SecureRandom).to receive(:urlsafe_base64).and_return('random_filename')

      expect(subject).to eq '/tmp/random_filename.pdf'
    end
  end
end
