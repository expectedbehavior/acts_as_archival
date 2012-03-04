require_relative "test_helper"

class ActsAsArchivalTest < ActiveSupport::TestCase
  def setup
    super
    @hole     = Hole.create(:number => 14)
    @readonly_hole = Hole.create(:number => 15)
    @readonly_hole.readonly!
    @muskrat  = @hole.muskrats.create(:name => "Steady Rat")
    @mole     = @hole.moles.create(:name => "Grabowski")
    @archived = Hole.create(:number => 12)
    @archived.archive
    @readonly_archived = Hole.create(:number => 13)
    @readonly_archived.archive
    @readonly_archived.readonly!
  end

  test "archiving items with polymorphic associations succeeds" do
    @muskrat = Muskrat.create(:name => "Algernon")
    @tick = Tick.create
    @muskrat.ixodidaes.create(:tick => @tick)
    @muskrat.archive
    assert @muskrat.reload.archived?
  end
end
