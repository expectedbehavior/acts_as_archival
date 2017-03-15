# frozen_string_literal: true
require_relative "test_helper"

class ColumnTest < ActiveSupport::TestCase
  test "acts_as_archival raises during create if missing archived_at column" do
    assert_raises(ExpectedBehavior::ActsAsArchival::MissingArchivalColumnError) {
      MissingArchivedAt.create!(name: "foo-foo")
    }
  end

  test "acts_as_archival raises during create if missing archive_number column" do
    assert_raises(ExpectedBehavior::ActsAsArchival::MissingArchivalColumnError) {
      MissingArchiveNumber.create!(name: "rover")
    }
  end
end
