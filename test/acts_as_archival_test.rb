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

  test "archival works when mass attribute assignment protection is present" do
    snake = Snake.create(:color => "pink")

    snake.archive
    assert snake.archive_number
    assert snake.archived_at

    snake.unarchive
    assert snake.archive_number.nil?
    assert snake.archived_at.nil?
  end

  test "readonly_when_archived flag works" do

    #not readonly_when_archived
    snake = Snake.create(:color => "pink")
    snake.archive
    assert_equal "pink", snake.color
    snake.color = "blue"
    assert snake.save
    snake.reload
    assert_equal "blue", snake.color
    snake.unarchive
    assert_equal "blue", snake.color
    snake.color = "pink"
    assert snake.save
    snake.reload
    assert_equal "pink", snake.color

    #readonly_when_archived
    beaver = Beaver.create(:how_much_wood_can_it_chuck => 5)
    beaver.archive
    assert_equal 5, beaver.how_much_wood_can_it_chuck
    beaver.how_much_wood_can_it_chuck = 10
    assert_not beaver.save
    assert_equal "Cannot modifify an archived record.", beaver.errors.full_messages.first
    beaver.reload
    assert_equal 5, beaver.how_much_wood_can_it_chuck
    beaver.unarchive
    assert_equal 5, beaver.how_much_wood_can_it_chuck
    beaver.how_much_wood_can_it_chuck = 10
    assert beaver.save
    beaver.reload
    assert_equal 10, beaver.how_much_wood_can_it_chuck
  end
end
