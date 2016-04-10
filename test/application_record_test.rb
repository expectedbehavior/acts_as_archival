require_relative "test_helper"

# Rails 5 introduced a new base class, and this is gonna test that
if defined?(ApplicationRecord)
  class ApplicationRecordTest < ActiveSupport::TestCase
    test "archive archives the record" do
      archival = ApplicationRecordRow.create!
      archival.archive
      assert archival.reload.archived?
    end

    test "unarchive unarchives archival records" do
      archival = ApplicationRecordRow.create!(:archived_at => Time.now, :archive_number => 1)
      archival.unarchive
      assert_not archival.reload.archived?
    end
  end
end
