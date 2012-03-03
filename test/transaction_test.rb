require_relative "test_helper"
require "rr"

class TransactionTest < ActiveSupport::TestCase
  include RR::Adapters::TestUnit

  test "archiving is transactional" do
    archival = Archival.create!
    exploder = archival.kids.create!
    any_instance_of(Kid) do |kid|
      stub(kid).archive { raise "Rollback Imminent" }
    end
    archival.archive

    assert_not archival.archived?, "If this failed, you might be trying to test on a system that doesn't support nested transactions"
    assert_not exploder.reload.archived?
  end

  test "unarchiving is transactional" do
    archival = Archival.create!
    exploder = archival.kids.create!
    any_instance_of(Kid) do |kid|
      stub(kid).unarchive { raise "Rollback Imminent" }
    end
    archival.archive
    archival.unarchive

    assert archival.reload.archived?
    assert exploder.reload.archived?
  end

end
