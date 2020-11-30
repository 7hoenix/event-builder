require 'ostruct'
require 'pry'
require './lib/ui'
require './lib/repo'

require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

class Linker
  def initialize(main_calendar, link_calendar)
    @main_calendar = main_calendar
    @link_calendar = link_calendar
  end

  def separator
    "-------------------------------------"
  end

  def list_main_calendar_events()
    puts "Linkable events:"
    possible_link_targets = @main_calendar.list_events(10)
    display_events(possible_link_targets)
  end

  def create_habit()
    puts "What habit are we creating?"
    habit = UI.get_user_input()
    selected_targets = create_links(habit)
    selected_targets.each { |event| @link_calendar.create_event(event) }
    metadata = @link_calendar.get_metadata()
    repo = Repo.new()
    repo.load(metadata.description)
    repo.upsert(habit, selected_targets.map { |event| Time.iso8601(event.start.date_time) })
    updated_metadata_description = repo.to_flat_file()
    metadata.description = updated_metadata_description
    @link_calendar.update_metadata(metadata)
  end

  def resolve()
    metadata = @link_calendar.get_metadata()
    repo = Repo.new()
    repo.load(metadata.description)
    expired_links = repo.expired_links()
    if expired_links.empty?
      puts "All loops still in effect. Carry on."
      return
    end
    expired_links.each do |link|
      puts "Resolving: #{link.skill}."
      selected_targets = create_links(link.skill)
      selected_targets.each { |event| @link_calendar.create_event(event) }
      if selected_targets.length > 0
        repo.upsert(link.skill, selected_targets.map { |event| Time.iso8601(event.start.date_time) })
      end
    end
    updated_metadata_description = repo.to_flat_file()
    metadata.description = updated_metadata_description
    @link_calendar.update_metadata(metadata)
  end

  def display_events(possible_link_targets)
    possible_link_targets.each_with_index do |target, i|
      puts "#{separator()}"
      puts "#{i + 1}: #{target.summary}"
    end
  end

  def create_links(habit)
    puts "What event(s) are we linking #{habit} to?"
    possible_link_targets = @main_calendar.list_events(10)
    display_events(possible_link_targets)

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
    selected_targets.map do |event|
      start_time = event.start.date || event.start.date_time
      end_time = Time.at(start_time.to_time + 900)

      start_date = Linker.make_time(start_time)
      end_date = Linker.make_time(end_time)
      Linker.make_event(start_date, end_date, habit)
    end
  end

  def self.make_time(time)
    Google::Apis::CalendarV3::EventDateTime.new(date_time: time.iso8601)
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
