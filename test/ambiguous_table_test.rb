require_relative "test_helper"

class AmbiguousTableTest < ActiveSupport::TestCase
  # test against the problem fixed in http://github.com/DarkTatka/acts_as_archival/commit/63d0a2532a15d7a6ab41d081e1591108a5ea9b37
  test "no ambiguous table problem" do
    archival = Archival.create!(:name => "TEST")
    child = archival.archivals.create!
    child.archive

    assert_equal 1, Archival.unarchived.count(:joins => :archivals)
  end
end
