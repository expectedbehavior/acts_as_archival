require_relative "test_helper"

class ThroughAssociationTest < ActiveSupport::TestCase

  test "archive a through associated object whose 'bridge' is archival" do
    archival = Archival.create!
    bridge   = archival.archival_kids.create!
    through  = bridge.archival_grandkids.create!
    archival.archive

    assert archival.reload.archived?
    assert bridge.reload.archived?
    assert through.reload.archived?
  end

  # TODO: Make something like this pass
  # test "archive a through associated object whose 'bridge' is not archival" do
  #   archival = Archival.create!
  #   bridge   = archival.independent_archival_kids.create!
  #   through  = bridge.archival_grandkids.create!
  #   archival.archive

  #   assert archival.reload.archived?
  #   assert through.reload.archived?
  # end

end
