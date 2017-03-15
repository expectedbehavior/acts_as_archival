require_relative 'test_helper'

class ReadonlyWhenArchivedTest < ActiveSupport::TestCase
  test 'acts_as_archival objects can normally be altered after archive' do
    archival = Archival.create!(name: 'original')
    archival.archive
    archival.name = 'updated'
    archival.save!

    assert_equal 'updated', archival.reload.name
  end

  test 'acts_as_archival marked as readonly_when_archived cannot be updated after archive' do
    archival = ReadonlyWhenArchived.create!(name: 'original')
    archival.archive
    archival.name = 'updated'

    assert_not archival.save
    assert_equal 'Cannot modify an archived record.',
                 archival.errors.full_messages.first
  end
end
