require './lib/ui'
require './lib/calendar'
require './lib/linker'

require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

require 'ostruct'




OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'integrate'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_EVENTS

MAIN_CALENDAR_KEY = ENV["MAIN_CALENDAR_KEY"]
LINK_CALENDAR_KEY = ENV["LINK_CALENDAR_KEY"]
LINK_METADATA_EVENT_ID = ENV["LINK_METADATA_EVENT_ID"]
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

# Initialize the API
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# Fetch the next 10 events for the user

# response = service.list_events(CALENDAR_KEY,
#                                max_results: 10,
#                                single_events: true,
#                                order_by: 'startTime',
#                                time_min: Time.now.iso8601)


Option = Struct.new(:title, :action)

if MAIN_CALENDAR_KEY.nil?
  raise "Must configure MAIN_CALENDAR_KEY env variable."
end
if LINK_CALENDAR_KEY.nil?
  raise "Must configure LINK_CALENDAR_KEY env variable."
end
main_calendar = ReadOnlyCalendar.new(service, MAIN_CALENDAR_KEY)
link_calendar = AutomatedCalendar.new(service, LINK_CALENDAR_KEY, LINK_METADATA_EVENT_ID)
linker = Linker.new(main_calendar, link_calendar)

# link_create_options = [
#   Option.new("Enter skill details", lambda { || gets }),
# ]
# link_options = [
#   Option.new("List Current Links", lambda { || linker.list_links() }),
#   Option.new("Create Link", lambda { || linker.create_link() }),
# ]
options = [
  Option.new("List Main Calendar Events", lambda { || linker.list_main_calendar_events() }),
  Option.new("Create Habit Link", lambda { || linker.create_habit() }),
  Option.new("Resolve", lambda { || linker.resolve() }),
]
# Could accept sequence as option.
UI.prompt(options)
