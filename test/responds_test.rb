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

  ### Deprecation Zone ###

  test "archival class responds correctly to 'is_archival?'" do
    ActiveSupport::Deprecation.silence do
      assert     Archival.is_archival?
      assert_not Plain.is_archival?
    end
  end

  test "archival object responds correctly to 'is_archival?'" do
    ActiveSupport::Deprecation.silence do
      assert     Archival.new.is_archival?
      assert_not Plain.new.is_archival?
    end
  end

end
