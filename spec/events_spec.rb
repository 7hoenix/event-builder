require('./lib/events')

RSpec.describe Events do
  describe ".find_dates" do
    it "finds a random date in the next month" do
      dates = Events.find_dates()
      expect(dates).to eq(2)
    end
  end
end
