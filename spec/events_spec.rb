require('./lib/events')

RSpec.describe Events do
  describe ".find_dates" do
    it "finds a random date in the next month" do
      fake_sample = lambda { |entries| entries.first }

      dates = Events.find_dates(fake_sample, 30)

      expect(dates.length).to eq(1)
      expect(dates[0]).to eq((Time.now + 86_400).strftime("%F"))
    end

    it "finds two dates" do
      fake_sample = lambda { |entries| entries.first }

      dates = Events.find_dates(fake_sample, 60)

      expect(dates.length).to eq(2)
      expect(dates[0]).to eq((Time.now + 86_400).strftime("%F"))
      expect(dates[1]).to eq((Time.now + 86_400 * 31).strftime("%F"))
    end

    it "will take partial months" do
      fake_sample = lambda { |entries| entries.first }

      dates = Events.find_dates(fake_sample, 61)

      expect(dates.length).to eq(3)
      expect(dates[0]).to eq((Time.now + 86_400).strftime("%F"))
      expect(dates[1]).to eq((Time.now + 86_400 * 31).strftime("%F"))
      expect(dates[2]).to eq((Time.now + 86_400 * 61).strftime("%F"))
    end
  end
end
