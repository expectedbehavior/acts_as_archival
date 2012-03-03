require_relative "test_helper"

class DeepNestingTest < ActiveSupport::TestCase
  test "archiving deeply nested items" do
    @hole.muskrats.first.fleas << Flea.create(:name => "Wadsworth")
    @hole.archive
    assert @hole.reload.archived?
    assert @hole.muskrats.first.reload.archived?
    assert @hole.muskrats.first.fleas.first.archived?
  end

  test "unarchiving deeply nested items doesn't blow up" do
    @hole.muskrats.first.fleas << Flea.create(:name => "Wadsworth")
    @hole.archive

    @hole.unarchive
    assert_not @hole.reload.archived?
    assert_not @hole.muskrats.first.reload.archived?
    assert_not @hole.muskrats.first.fleas.first.archived?
  end
end
