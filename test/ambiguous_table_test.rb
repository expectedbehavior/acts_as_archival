require_relative "test_helper"

class AmbiguousTableTest < ActiveSupport::TestCase

  test "no ambiguous table problem" do
    archival = Archival.create!
    child = archival.archivals.create!
    child.archive

    # this is a bug fix for a problem wherein table names weren't being
    # namespaced, so if a table joined against itself, incorrect SQL was
    # generated
    assert_equal 1, Archival.unarchived.joins(:archivals).count
  end

end
