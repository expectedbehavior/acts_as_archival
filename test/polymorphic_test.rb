# frozen_string_literal: true
require_relative 'test_helper'

class PolymorphicTest < ActiveSupport::TestCase
  test 'archive item with polymorphic association' do
    archival = Archival.create!
    poly = archival.polys.create!
    archival.archive

    assert archival.reload.archived?
    assert poly.reload.archived?
  end

  test 'unarchive item with polymorphic association' do
    archive_attributes = {
      archive_number: 'test',
      archived_at: Time.now
    }
    archival = Archival.create!(archive_attributes)
    poly = archival.polys.create!(archive_attributes)
    archival.unarchive

    assert_not archival.reload.archived?
    assert_not poly.reload.archived?
  end
end
