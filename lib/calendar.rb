require 'ostruct'
require 'pry'
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

class Calendar
  def initialize(service, calendar_key, link_metadata_event_id = "", timer = lambda { Time.now })
    @service = service
    @calendar_key = calendar_key
    @link_metadata_event_id = link_metadata_event_id
    @timer = timer
  end

  def list_events(max_results)
    options = {
      max_results: max_results,
      single_events: true,
      order_by: 'startTime',
      time_min: @timer.call().iso8601
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

  def get_metadata()
    # Ensure that metadata is more than 7 days out
    metadata = @service.get_event(@calendar_key, @link_metadata_event_id)
    current_time = @timer.call()
    if metadata.start.date_time.to_time - (current_time + (7 * 86400)) <= 0
      start_a_week_later = metadata.start.date_time.to_time + (7 * 86400)
      end_a_week_later = start_a_week_later + 3600
      metadata.start = Google::Apis::CalendarV3::EventDateTime.new(date_time: start_a_week_later.iso8601)
      metadata.end = Google::Apis::CalendarV3::EventDateTime.new(date_time: end_a_week_later.iso8601)
      @service.update_event(@calendar_key, @link_metadata_event_id, metadata)
      @service.get_event(@calendar_key, @link_metadata_event_id)
    else
      metadata
    end
  end

  def in_the_past(datetime)
    current_time = @timer.call()
    last_recorded = Time.iso8601(datetime)
    last_recorded - current_time <= 0
  end
end
