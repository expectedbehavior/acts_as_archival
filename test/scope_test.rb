require_relative "test_helper"

class ActsAsArchivalTest < ActiveSupport::TestCase
  test "simple unarchived scope" do
    Archival.create!
    Archival.create!

    assert_equal 2, Archival.unarchived.count
  end

  test "simple archived scope" do
    Archival.create!.archive
    Archival.create!.archive

    assert_equal 2, Archival.archived.count
  end

  test "mixed scopes" do
    Archival.create!
    Archival.create!.archive

    assert_equal 1, Archival.archived.count
    assert_equal 1, Archival.unarchived.count
  end

  test "simple archived_from_archive_number" do
    archive_number = "TEST-IT"
    Archival.create!.archive(archive_number)
    Archival.create!.archive(archive_number)

    assert_equal 2, Archival.archived_from_archive_number(archive_number).count
  end

  test "negative archived_from_archive_number" do
    archive_number = "TEST-IT"
    bogus_number = "BROKE-IT"
    Archival.create!.archive(archive_number)
    Archival.create!.archive(archive_number)

    assert_equal 0, Archival.archived_from_archive_number(bogus_number).count
  end

  test "mixed archived_from_archive_number" do
    archive_number = "TEST-IT"
    Archival.create!.archive(archive_number)
    Archival.create!.archive

    assert_equal 1, Archival.archived_from_archive_number(archive_number).count
  end

  test "table_name is set to 'legacy'" do
    assert_equal "SELECT `legacy`.* FROM `legacy`  WHERE (legacy.archived_at IS NOT NULL AND legacy.archive_number IS NOT NULL)", ArchivalTableName.archived.to_sql
    assert_equal "SELECT `legacy`.* FROM `legacy`  WHERE `legacy`.`archived_at` IS NULL AND `legacy`.`archive_number` IS NULL", ArchivalTableName.unarchived.to_sql
  end
end
