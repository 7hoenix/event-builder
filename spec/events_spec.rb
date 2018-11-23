require('./lib/events')

RSpec.describe Events do
  describe ".find_dates" do
    it "finds a random date in the next month" do
      fake_sample = lambda { |entries| entries.first }

      dates = Events.find_dates(fake_sample, 30)

      expect(dates.length).to eq(1)
      expect(convert_date(dates[0])).to eq(convert_date(Time.now + 86_400))
    end

    it "finds two dates" do
      fake_sample = lambda { |entries| entries.first }

      dates = Events.find_dates(fake_sample, 60)

      expect(dates.length).to eq(2)
      expect(convert_date(dates[0])).to eq(convert_date(Time.now + 86_400))
      expect(convert_date(dates[1])).to eq(convert_date(Time.now + 86_400 * 31))
    end

    it "will take partial months" do
      fake_sample = lambda { |entries| entries.first }

      dates = Events.find_dates(fake_sample, 61)

      expect(dates.length).to eq(3)
      expect(convert_date(dates[0])).to eq(convert_date(Time.now + 86_400))
      expect(convert_date(dates[1])).to eq(convert_date(Time.now + 86_400 * 31))
      expect(convert_date(dates[2])).to eq(convert_date(Time.now + 86_400 * 61))
    end

    def convert_date(time)
      time.strftime("%F")
    end
  end
end
