require('./lib/repo')
require('./lib/util')
require('pry')


FLAT_FILE = """========== METADATA DO NOT EDIT BY HAND ==========
Skill A##2020-12-05T03:00:00-06:00
Skill B##2020-12-06T03:00:00-06:00
Skill C##2020-12-07T03:00:00-06:00"""

EMPTY_FILE = """========== METADATA DO NOT EDIT BY HAND ==========
"""

RSpec.describe Repo do
  describe ".load" do
    # TODO: assumes that the given metadata file is well formed
    it "will load from a flat file" do
      time = Time.iso8601("2020-12-06T03:00:00-06:00")
      timer = lambda { || timestamp }
      repo = Repo.new

      repo.load(FLAT_FILE)

      expected_links = [
        Link.new("Skill A", Time.iso8601("2020-12-05T03:00:00-06:00")),
        Link.new("Skill B", Time.iso8601("2020-12-06T03:00:00-06:00")),
        Link.new("Skill C", Time.iso8601("2020-12-07T03:00:00-06:00")),
      ]
      expect(repo.links).to eq(expected_links)
    end
  end

  describe ".upsert" do
    it "will insert the only the latest link" do
      # TODO: Can we add to the past?
      now = Time.now
      soon = now + 1
      tomorrow = Util.days(now, 1)
      day_after_tomorrow = Util.days(now, 2)
      skill = "New Skill"
      repo = Repo.new

      repo.upsert(skill, [soon, tomorrow, day_after_tomorrow])

      expect(repo.links).to eq([Link.new("New Skill", day_after_tomorrow)])
    end

    it "will overwrite an existing skill if already present" do
      now = Time.now
      soon = now + 1
      tomorrow = Util.days(now, 1)
      skill = "New Skill"
      repo = Repo.new
      repo.upsert(skill, [soon])

      repo.upsert(skill, [tomorrow])

      expect(repo.links).to eq([Link.new("New Skill", tomorrow)])
    end

    it "will also compare the current time if its set" do
      now = Time.now
      soon = now + 1
      tomorrow = Util.days(now, 1)
      skill = "New Skill"
      repo = Repo.new
      repo.upsert(skill, [tomorrow])

      repo.upsert(skill, [soon])

      expect(repo.links).to eq([Link.new("New Skill", tomorrow)])
    end
  end

  describe ".to_flat_file" do
    it "will round trip" do
      repo = Repo.new
      repo.load(FLAT_FILE)

      flat_file = repo.to_flat_file()

      expect(flat_file).to eq(FLAT_FILE)
    end

    it "will round trip an empty file" do
      repo = Repo.new
      repo.load(EMPTY_FILE)

      flat_file = repo.to_flat_file()

      expect(flat_file).to eq(EMPTY_FILE)
    end
  end

  describe ".expired_links" do
    it "returns links that are in the past" do
      now = Time.now
      timer = lambda { || now }
      repo = Repo.new(timer)
      now = Time.now
      yesterday = Util.days(now, -1)
      soon = now + 1
      tomorrow = Util.days(now, 1)
      link_c = Link.new("Skill C", soon)
      link_d = Link.new("Skill D", tomorrow)
      repo.upsert("Skill A", [yesterday])
      repo.upsert("Skill B", [now])
      repo.upsert("Skill C", [soon])
      repo.upsert("Skill D", [tomorrow])

      expired_links = repo.expired_links()

      expected_expired_links = [
        link_a = Link.new("Skill A", yesterday),
        link_b = Link.new("Skill B", now)
      ]
      expect(expired_links).to eq(expected_expired_links)
    end
  end
end
