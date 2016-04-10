require_relative "test_helper"

class BasicTest < ActiveSupport::TestCase
  test "archive archives the record" do
    archival = Archival.create!
    archival.archive
    assert_equal true, archival.reload.archived?
  end

  test "unarchive unarchives archival records" do
    archival = Archival.create!(:archived_at => Time.now, :archive_number => 1)
    archival.unarchive
    assert_equal false, archival.reload.archived?
  end

  test "archive returns true on success" do
    normal = Archival.create!
    assert_equal true, normal.archive
  end

  test "archive returns false on failure" do
    readonly = Archival.create!
    readonly.readonly!
    assert_equal false, readonly.archive
  end

  test "unarchive returns true on success" do
    normal = Archival.create!(:archived_at => Time.now, :archive_number => "1")
    assert_equal true, normal.unarchive
  end

  test "unarchive returns false on failure" do
    readonly = Archival.create!(:archived_at => Time.now, :archive_number => "1")
    readonly.readonly!
    assert_equal false, readonly.unarchive
  end

  test "archive sets archived_at to the time of archiving" do
    archival = Archival.create!
    before = DateTime.now
    sleep(0.001)
    archival.archive
    sleep(0.001)
    after = DateTime.now
    assert before < archival.archived_at.to_datetime
    assert after  > archival.archived_at.to_datetime
  end

  test "archive sets the archive number to the md5 hexdigest for the model and id that is archived" do
    archival = Archival.create!
    archival.archive
    expected_digest = Digest::MD5.hexdigest("#{archival.class.name}#{archival.id}")
    assert_equal expected_digest, archival.archive_number
  end

  test "archive on archived object doesn't alter the archive_number" do
    archived = Archival.create
    archived.archive
    initial_number = archived.archive_number
    archived.reload.archive
    second_number = archived.archive_number
    assert_equal initial_number, second_number
  end
end
