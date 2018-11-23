require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'pry'

require './lib/events'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Gift Calendar Generator'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_EVENTS

CALENDAR_KEY = ENV["CALENDAR_KEY"]
TARGET_IN_DAYS = 2830

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

def make_date(raw)
  Google::Apis::CalendarV3::EventDateTime.new(date: raw.strftime("%F"))
end

def days(count)
  count * 86400
end

# 510 minutes is 3:30PM the day before.
def make_reminder(minutes_before = 510)
  Google::Apis::CalendarV3::EventReminder.new({
    minutes: minutes_before,
    reminder_method: 'popup'
  })
end

def make_event(time)
  start_date = make_date(time)
  end_date = make_date(time + days(1))
  Google::Apis::CalendarV3::Event.new({
    summary: 'Time to give a gift',
    description: 'Make it better than the last one',
    start: start_date,
    end: end_date,
    reminders: Google::Apis::CalendarV3::Event::Reminders.new(
      overrides: [
        make_reminder(510),
        make_reminder(630)
      ],
      use_default: false
    )
  })
end


# Initialize the API
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# Fetch the next 10 events for the user

response = service.list_events(CALENDAR_KEY,
                               max_results: 10,
                               single_events: true,
                               order_by: 'startTime',
                               time_min: Time.now.iso8601)



puts 'Upcoming events:'
puts 'No upcoming events found' if response.items.empty?
response.items.each do |event|
  start = event.start.date || event.start.date_time
  puts "- #{event.summary} (#{start})"
end

puts 'generating dates'
dates = Events.find_dates(TARGET_IN_DAYS)
dates.each do |date|
  event = make_event(date)
  puts 'making event for: ' + event.start.date
  service.insert_event(CALENDAR_KEY, event)
end
