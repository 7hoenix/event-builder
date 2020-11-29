require 'ostruct'
require 'pry'
require './lib/ui'


require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

Option = Struct.new(:title, :action)

class Linker
  def initialize(main_calendar, link_calendar)
    @main_calendar = main_calendar
    @link_calendar = link_calendar
  end

  def separator
    "-------------------------------------"
  end

  def create_habit()
    puts "What habit are we creating?"
    habit = UI.get_user_input()
    puts "What event(s) are we linking it to?"
    possible_link_targets = @main_calendar.list_events(10)
    possible_link_targets.each_with_index do |target, i|
      puts "#{separator()}"
      puts "#{i + 1}: #{target.summary}"
    end

    selected_targets = []
    done_selecting = false
    puts "Enter selections (d to finish):"
    while not done_selecting
      selection = UI.get_user_input()
      if selection == 'd'
        done_selecting = true
      elsif is_i?(selection)
        target = possible_link_targets[selection.to_i - 1]
        if selection.to_i < 1 || selection.to_i > possible_link_targets.length
          puts "Must be between 1 and #{possible_link_targets.length}"
        elsif selected_targets.include?(target)
          puts "Already selected."
        else
          selected_targets.append(possible_link_targets[selection.to_i - 1])
        end
        puts "Selected: #{selected_targets.map { |t| t.summary }}"
      else
        puts "Must put an integer or 'd' for 'done'."
      end
    end

    selected_targets.each do |event|
      start_time = event.start.date || event.start.date_time
      end_time = Time.at(start_time.to_time + 86400)

      start_date = Linker.make_time(start_time)
      end_date = Linker.make_time(end_time)
      event = Linker.make_event(start_date, end_date, habit)
      @link_calendar.create_event(event)
    end
  end

  def resolve()
    split = "========== METADATA DO NOT EDIT BY HAND =========="
    metadata = @link_calendar.get_metadata()
    raw_data = metadata.description.split(split)[1].strip
    habits = raw_data.split("||")
    habits.each do |habit|
      raise "metadata is poorly formed" if habit.split("##").length > 2
      skill, last_recorded_date = habit.split("##")
      puts "Resolving: #{skill}."
      if @link_calendar.in_the_past(last_recorded_date)
        puts "Habit found that is not being tracked"
      else
        puts "Still have at least 1 scheduled."
        puts "Want to add more?"
      end
    end
  end


  def self.make_time(time)
    Google::Apis::CalendarV3::EventDateTime.new(date: time.strftime("%F"))
  end

  def self.make_reminder(minutes_before = 20)
    Google::Apis::CalendarV3::EventReminder.new({
      minutes: minutes_before,
      reminder_method: 'popup'
    })
  end

  def self.make_event(start_date, end_date, habit)
    Google::Apis::CalendarV3::Event.new({
      summary: habit,
      description: "foo",
      start: start_date,
      end: end_date,
      reminders: Google::Apis::CalendarV3::Event::Reminders.new(
        overrides: [
          Linker.make_reminder(20),
        ],
        use_default: false
      )
    })
  end

  # TODO: where should this go?
  def is_i?(s)
    !!(s =~ /\A[-+]?[0-9]+\z/)
  end
end
