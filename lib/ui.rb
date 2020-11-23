class UI

  def self.prompt(options)
    result = nil
    while result.nil?
      begin
        self.present_menu(options)
        result = self.get_input(options)
      rescue
      retry
      end
    end
  end

  def self.get_input(options, get_user_input= lambda { || gets })
    raw = get_user_input.call()
    selection = Integer(raw)
    if selection > options.length || selection <= 0
      options_message = options.each_with_index.map { |option, i| "#{i + 1} for #{option}" }
      raise "Must choose from #{options_message}"
    end
    options[selection - 1]
  end

  def self.present_menu(options, printer= lambda { |menu| puts menu })
    formatted_prompt = [
      "Please Select (numbers only):"
    ] + options.each_with_index.map { |option, i| "#{i + 1}: #{option}" }
    printer.call(formatted_prompt.join("\n"))
  end
end
