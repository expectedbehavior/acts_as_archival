require_relative "test_helper"

class AmbiguousTableTest < ActiveSupport::TestCase
  # test against the problem fixed in http://github.com/DarkTatka/acts_as_archival/commit/63d0a2532a15d7a6ab41d081e1591108a5ea9b37
  test "no ambiguous table problem" do
    archival = Archival.create!(:name => "TEST")
    child = archival.kids.create!
    child.archive

    assert_equal 1, Kid.archived.count(:conditions => ["archivals.name=?", archival.name],
                                       :joins => :archival)
    # @hole.muskrats.first.archive
    # assert_equal 1, Muskrat.archived.all(:conditions => "holes.number = '14'", :joins => :hole).size
  end
end
