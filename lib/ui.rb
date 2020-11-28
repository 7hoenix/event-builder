require 'pry'

class UI

  def self.prompt(options)
    # quit = false
    # while !quit
      # begin
        self.present_menu(options)
        option = self.choose_option(options)
        option.action.call()
        #puts result.action
      # rescue
      #   binding.pry
      # retry
      # end
    # end
  end

  def self.choose_option(options, get_user_input= lambda { || gets })
    raw = get_user_input.call()
    selection = Integer(raw)
    if selection > options.length || selection <= 0
      options_message = options.each_with_index.map { |option, i| "#{i + 1} for #{option.title}" }
      raise "Must choose from #{options_message}"
    end
    options[selection - 1]
  end

  def self.present_menu(options, printer= lambda { |menu| puts menu })
    formatted_prompt = [
      "Please Select (numbers only):"
    ] + options.each_with_index.map { |option, i| "#{i + 1}: #{option.title}" }
    printer.call(formatted_prompt.join("\n"))
  end

  def self.get_user_input(getter = lambda { || gets.chomp })
    getter.call()
  end
end
