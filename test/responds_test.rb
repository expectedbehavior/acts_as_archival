require_relative "test_helper"

class RespondsTest < ActiveSupport::TestCase

  test "archival class responds correctly to 'archival?'" do
    assert     Archival.archival?
    assert_not Plain.archival?
  end

  test "archival object responds correctly to 'archival?'" do
    assert     Archival.new.archival?
    assert_not Plain.new.archival?
  end

end
