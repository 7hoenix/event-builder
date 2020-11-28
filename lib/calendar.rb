require 'ostruct'
require 'pry'

class Calendar
  def initialize(service, calendar_key, timer = lambda { Time.now.iso8601 })
    @service = service
    @calendar_key = calendar_key
    @timer = timer
  end

  def list_events(max_results)
    options = {
      max_results: max_results,
      single_events: true,
      order_by: 'startTime',
      time_min: @timer.call()
    }
    response = @service.list_events(@calendar_key, options)
    puts "got response"
    puts response.items
    response.items
  end

  # TODO: MAKE READONLY OPTION
  def create_event(event)
    @service.insert_event(@calendar_key, event)
  end
end
