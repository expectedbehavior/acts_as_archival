require_relative "test_helper"

class ColumnTest < ActiveSupport::TestCase
  test "including archival throws exceptions if the correct columns aren't in place" do
    assert_raises(ExpectedBehavior::ActsAsArchival::MissingArchivalColumnError) { Kitty.create!(:name => "foo-foo")}
    assert_raises(ExpectedBehavior::ActsAsArchival::MissingArchivalColumnError) { Puppy.create!(:name => "rover")}
  end
end
