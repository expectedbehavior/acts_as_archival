require_relative "test_helper"

class SetterTest < ActiveSupport::TestCase
  test "archive= works" do
    archival = Archival.create!
    archival.archived = true

    assert archival.archived?
  end
end
