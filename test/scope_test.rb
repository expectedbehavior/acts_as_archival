require_relative "test_helper"

class ScopeTest < ActiveSupport::TestCase

  test "simple unarchived scope" do
    Archival.create!
    Archival.create!

    assert_equal 2, Archival.unarchived.count
  end

  test "simple archived scope" do
    Archival.create!.archive!
    Archival.create!.archive!

    assert_equal 2, Archival.archived.count
  end

  test "mixed scopes" do
    Archival.create!
    Archival.create!.archive!

    assert_equal 1, Archival.archived.count
    assert_equal 1, Archival.unarchived.count
  end

  test "simple archived_from_archive_number" do
    archive_number = "TEST-IT"
    Archival.create!.archive!(archive_number)
    Archival.create!.archive!(archive_number)

    assert_equal 2, Archival.archived_from_archive_number(archive_number).count
  end

  test "negative archived_from_archive_number" do
    archive_number = "TEST-IT"
    bogus_number = "BROKE-IT"
    Archival.create!.archive!(archive_number)
    Archival.create!.archive!(archive_number)

    assert_equal 0, Archival.archived_from_archive_number(bogus_number).count
  end

  test "mixed archived_from_archive_number" do
    archive_number = "TEST-IT"
    Archival.create!.archive!(archive_number)
    Archival.create!.archive!

    assert_equal 1, Archival.archived_from_archive_number(archive_number).count
  end

  test "table_name is set to 'legacy'" do
    archived_sql =
      if ActiveRecord.version >= Gem::Version.new("5.2.0")
        "SELECT \"legacy\".* FROM \"legacy\" " \
        'WHERE "legacy"."archived_at" IS NOT NULL AND "legacy"."archive_number" IS NOT NULL'
      else
        "SELECT \"legacy\".* FROM \"legacy\" " \
        'WHERE ("legacy"."archived_at" IS NOT NULL) AND ("legacy"."archive_number" IS NOT NULL)'
      end
    unarchived_sql = "SELECT \"legacy\".* FROM \"legacy\" " \
        'WHERE "legacy"."archived_at" IS NULL AND "legacy"."archive_number" IS NULL'
    assert_equal archived_sql, ArchivalTableName.archived.to_sql
    assert_equal unarchived_sql, ArchivalTableName.unarchived.to_sql
  end

  test "combines with other scope properly" do
    Archival.create!(name: "Robert")
    Archival.create!(name: "Bobby")
    Archival.create!(name: "Sue")
    bob = Archival.create!(name: "Bob")
    bob.archive!
    assert_equal 3, Archival.bobs.count
    assert_equal 3, Archival.unarchived.count
    assert_equal 2, Archival.bobs.unarchived.count
    assert_equal 2, Archival.unarchived.bobs.count
    assert_equal 1, Archival.bobs.archived.count
    assert_equal 1, Archival.archived.bobs.count
  end

  test "scopes combine with relations correctly" do
    parent = Archival.create!
    parent.archivals.create!
    parent.archivals.create!
    child = parent.archivals.create!
    child.archive!
    assert_equal 3, parent.archivals.count
    assert_equal 1, parent.archivals.archived.count
    assert_equal 2, parent.archivals.unarchived.count
  end

end
