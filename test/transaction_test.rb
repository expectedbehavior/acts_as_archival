require_relative "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "archiving is transactional" do
    archival = Archival.create!
    exploder = archival.explode_on_archive_kids.create!
    archival.archive

    assert_not archival.archived?, "If this failed, you might be trying to test on a system that doesn't support nested transactions"
    assert_not exploder.reload.archived?
  end

  test "unarchiving is transactional" do
    ship = Ship.create(:name => "HMS Holly Hawk")
    ship.oranges << Orange.create(:name => "Pennyworth")
    assert ship.is_archival?
    assert ship.oranges.first.is_archival?
    ship.archive
    ship.unarchive
    assert ship.reload.archived?
    assert ship.oranges(true).first.archived?
  end

end
