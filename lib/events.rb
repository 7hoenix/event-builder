module Events
  def self.find_dates(random = lambda { |entries| entries.sample() }, days_desired)
    result = []
    entries = build_entries(days_desired)
    entries.each_slice(30) { |approximate_month| result.push(random.call(approximate_month)) }
    result
  end

  private

  def self.build_entries(entries = [], current_day)
    if current_day == 0
      return entries.reverse
    end
    updated_entries = entries.concat([build_entry(current_day)])
    build_entries(updated_entries, current_day - 1)
  end

  def self.build_entry(day)
    (Time.now + 86_400 * day).strftime("%F")
  end
end
