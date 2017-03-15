require_relative 'test_helper'

class DeepNestingTest < ActiveSupport::TestCase
  test 'archiving deeply nested items' do
    archival   = Archival.create!
    child      = archival.archivals.create!
    grandchild = child.archivals.create!
    archival.archive
    assert archival.reload.archived?
    assert child.reload.archived?
    assert grandchild.reload.archived?
    assert_equal archival.archive_number, child.archive_number
    assert_equal archival.archive_number, grandchild.archive_number
  end

  test "unarchiving deeply nested items doesn't blow up" do
    archival_attributes = {
      archived_at: Time.now,
      archive_number: 'test'
    }
    archival   = Archival.create!(archival_attributes)
    child      = archival.archivals.create!(archival_attributes)
    grandchild = child.archivals.create!(archival_attributes)
    archival.unarchive
    assert_not archival.reload.archived?
    assert_not child.reload.archived?
    assert_not grandchild.reload.archived?
  end
end
