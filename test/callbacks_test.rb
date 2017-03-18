require_relative "test_helper"

class CallbacksTest < ActiveSupport::TestCase
  if defined?(ApplicationRecord)
    test "can set a value as part of archiving" do
      archival = CallbackArchival5.create
      archival.set_this_value = "a test string"
      assert_nil archival.settable_field
      archival.archive
      assert_equal "a test string", archival.reload.settable_field
    end

    test "can be halted" do
      archival = CallbackArchival5.create
      archival.set_this_value = "a test string"
      archival.pass_callback = false
      assert_nil archival.settable_field
      archival.archive
      assert_nil archival.reload.settable_field
    end
  else
    test "can set a value as part of archiving" do
      archival = CallbackArchival4.create
      archival.set_this_value = "a test string"
      assert_nil archival.settable_field
      archival.archive
      assert_equal "a test string", archival.reload.settable_field
    end

    test "can be halted" do
      archival = CallbackArchival4.create
      archival.set_this_value = "a test string"
      archival.pass_callback = false
      assert_nil archival.settable_field
      archival.archive
      assert_nil archival.reload.settable_field
    end
  end
end
