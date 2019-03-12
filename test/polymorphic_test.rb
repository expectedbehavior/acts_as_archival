require_relative "test_helper"

class PolymorphicTest < ActiveSupport::TestCase

  test "archive item with polymorphic association" do
    archival = Archival.create!
    poly = archival.polys.create!
    archival.archive!

    assert archival.reload.archived?
    assert poly.reload.archived?
  end

  test "does not archive polymorphic association of different item with same id" do
    archival = Archival.create!
    another_polys_holder = AnotherPolysHolder.create! id: archival.id
    poly = another_polys_holder.polys.create!
    archival.archive!

    assert_not poly.reload.archived?
  end

  test "unarchive item with polymorphic association" do
    archive_attributes = {
      archive_number: "test",
      archived_at: Time.now
    }
    archival = Archival.create!(archive_attributes)
    poly = archival.polys.create!(archive_attributes)
    archival.unarchive!

    assert_not archival.reload.archived?
    assert_not poly.reload.archived?
  end

  test "does not unarchive polymorphic association of different item with same id" do
    archive_attributes = {
      archive_number: "test",
      archived_at: Time.now
    }

    archival = Archival.create!(archive_attributes)
    another_polys_holder = AnotherPolysHolder.create!(archive_attributes.merge(id: archival.id))
    poly = another_polys_holder.polys.create!(archive_attributes)
    archival.unarchive!

    assert poly.reload.archived?
  end

end
