require('./lib/ui')

RSpec.describe UI do
  describe "UI.prompt" do
    xit "test the full loop" do
      # TODO
    end
  end

  describe "UI.get_input" do
    it "will allow user to select from given options" do
      option_1 = "new_habit"
      option_2 = "show_links"
      options = [option_1, option_2]
      user_input = "1"
      fake_gets = lambda { || user_input }

      selection = UI.get_input(options, fake_gets)

      expect(selection).to eq(option_1)
    end

    it "won't allow numbers that are not given options" do
      option_1 = "new_habit"
      option_2 = "show_links"
      options = [option_1, option_2]
      user_inputs = ["0", "-1", "3"] # Options without a user input possible seems bad.

      options_message = options.each_with_index.map { |option, i| "#{i + 1} for #{option}" }
      expected_message = "Must choose from #{options_message}"
      user_inputs.each do |user_input|
        fake_gets = lambda { || user_input }
        expect { UI.get_input(options, fake_gets) }.to raise_error(expected_message)
      end
    end

    it "won't allow other bad " do
      option_1 = "new_habit"
      option_2 = "show_links"
      options = [option_1, option_2]
      user_inputs = ["", " ", "a", "6a", "a7"]

      user_inputs.each do |user_input|
        fake_gets = lambda { || user_input }
        expect { UI.get_input(options, fake_gets) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "UI.present_menu" do
    it "will present the menu" do
      option_1 = "new_habit"
      option_2 = "show_links"
      options = [option_1, option_2]
      result = nil
      printer = lambda { |formatted| result = formatted }

      UI.present_menu(options, printer)

      expected_prompt = [
        "Please Select (numbers only):",
        "1: new_habit",
        "2: show_links"
      ]
      expect(result).to eq(expected_prompt.join("\n"))
    end
  end
end
