require_relative "test_helper"

class ActsAsArchivalTest < ActiveSupport::TestCase
  test "archive archives 'has_' associated archival objects that are dependent destroy" do
    archival = Archival.create!
    child = archival.kids.create!
    archival.archive

    assert archival.reload.archived?
    assert child.reload.archived?
  end

  test "archive does not archive 'has_' associated archival objects that are not dependent destroy" do
    archival = Archival.create!
    non_dependent_child = archival.independent_kids.create!
    archival.archive

    assert archival.reload.archived?
    assert_not non_dependent_child.reload.archived?
  end
end
