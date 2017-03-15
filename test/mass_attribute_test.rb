# frozen_string_literal: true
require_relative "test_helper"

class MassAttributeTest < ActiveSupport::TestCase
  if $require_mass_protection
    test "archive works when attr_accessible present" do
      archival = MassAttributeProtected.create(color: "pink")
      archival.archive

      assert archival.reload.archived?
    end

    test "unarchive works when attr_accessible present" do
      archival = MassAttributeProtected.create(color: "pink")
      archival.archive
      archival.unarchive

      assert_not archival.reload.archived?
    end
  end
end
