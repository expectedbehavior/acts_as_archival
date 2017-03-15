# frozen_string_literal: true
require_relative "test_helper"

class RespondsTest < ActiveSupport::TestCase
  test "archival class responds correctly to 'is_archival?'" do
    assert     Archival.is_archival?
    assert_not Plain.is_archival?
  end

  test "archival object responds correctly to 'is_archival?'" do
    assert     Archival.new.is_archival?
    assert_not Plain.new.is_archival?
  end
end
