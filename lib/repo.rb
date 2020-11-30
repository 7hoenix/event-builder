require 'ostruct'

Link = Struct.new(:skill, :last_scheduled)

class Repo
  HEADER = "========== METADATA DO NOT EDIT BY HAND =========="
  attr_reader :links

  def initialize(timer = lambda { || Time.now })
    @links = []
    @timer = timer
  end

  def load(flat_file)
    raw_data = flat_file.split(HEADER)[1].strip
    habits = raw_data.split("\n")
    @links = habits.map do |habit|
      # raise "metadata is poorly formed" if habit.split("##").length > 2
      skill, last_recorded_date = habit.split("##")
      Link.new(skill, Time.iso8601(last_recorded_date))
    end
  end

  def upsert(skill, event_times)
    already_practicing = @links.find { |link| link.skill == skill }
    if already_practicing
      event_times_with_current = event_times + [already_practicing.last_scheduled]
      last_scheduled = event_times_with_current.sort { |a, b| a.to_i <=> b.to_i }.last
      @links = @links.map do |link|
        link.skill == skill ? Link.new(skill, last_scheduled) : link
      end
    else
      last_scheduled = event_times.sort { |a, b| a.to_i <=> b.to_i }.last
      @links.append(Link.new(skill, last_scheduled))
    end
  end

  def to_flat_file()
    pretty_links = @links.map do |link|
      "#{link.skill}###{link.last_scheduled.iso8601}"
    end
    HEADER + "\n" + pretty_links.join("\n")
  end

  def expired_links()
    current_time = @timer.call()
    @links.select { |link| link.last_scheduled - current_time <= 0 }
  end
end
