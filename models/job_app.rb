module WorkForwardNola
  class JobApp < Sequel::Model
    plugin :timestamps

    def yes_no(val)
      val ? 'yes' : 'no' unless val.nil?
    end
  end
end
