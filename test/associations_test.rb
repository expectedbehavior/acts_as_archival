require_relative "test_helper"

class ActsAsArchivalTest < ActiveSupport::TestCase
  test "archive archives 'has_' associated archival objects that are dependent destroy" do
    archival = Archival.create!
    child = archival.kids.create!
    archival.archive

    assert archival.reload.archived?
    assert child.reload.archived?
  end
end
