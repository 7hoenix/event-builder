require './lib/ui'

require 'ostruct'

Option = Struct.new(:title, :action)

class Calendar
  def initialize(calendar_key)
    @calendar_key = calendar_key
  end
end

class Action
  def self.list_calendar(calendar)
  end
end

main_calendar = Calendar.new("asht")
options = [
  Option.new("List Calendar Events", Action.list_calendar(main_calendar)),
]
UI.prompt(options)
