require('./lib/calendar')
require 'ostruct'

class Response
  attr_reader :items

  def initialize(items)
    @items = items
  end
end

class ServiceMock
  attr_accessor :calendar_key, :options

  def initialize(events)
    @events = events
  end

  def list_events(calendar_key, options)
    @calendar_key = calendar_key
    @options = options
    Response.new(@events)
  end
end

RSpec.describe Calendar do
  describe "Calendar.list_events" do
    it "will list the calendar events" do
      timestamp = Time.at(0)
      timer = lambda { || timestamp }
      calendar_key = "key"
      max_results = 10
      expected_options = {
        max_results: max_results,
        single_events: true,
        order_by: 'startTime',
        time_min: timestamp
      }
      events = [{foo: "cake"}]
      service_mock = ServiceMock.new(events)
      calendar = Calendar.new(service_mock, calendar_key, timer)

      actual_events = calendar.list_events(max_results)

      expect(service_mock.calendar_key).to eq(calendar_key)
      expect(service_mock.options).to eq(expected_options)
      expect(actual_events).to eq(events)
    end
  end
end
