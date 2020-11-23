require('./lib/ui')

RSpec.describe UI do
  describe "UI.present" do
    it "will allow user to select from given options" do
      option_1 = "new_habit"
      option_2 = "show_links"
      options = [option_1, option_2]
      user_input = "1"
      fake_gets = lambda { |_| user_input }

      selection = UI.present(fake_gets, options)

      expect(selection).to eq(option_1)
    end
  end
end
