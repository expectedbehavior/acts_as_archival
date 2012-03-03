require_relative "test_helper"

class ActsAsArchivalTest < ActiveSupport::TestCase
  def setup
    super
    DatabaseCleaner.clean
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

  test "unarchive retrieves 'has_' associated archival objects regardless of dependent destroy" do
    @hole.squirrels.create(:name => "Rocky")

    @hole.archive
    @hole.squirrels.first.update_attributes(:archive_number => @hole.archive_number, :archived_at => @hole.archived_at)

    assert @hole.reload.archived?
    assert @hole.squirrels(true).first.archived?

    @hole.unarchive

    assert_not @hole.reload.archived?
    assert_not @hole.squirrels(true).first.archived?
  end

  test "archive sets the archive number to the md5 hexdigest for the model and id of the head object that is archived for 'has_' associated archival objects" do
    assert @hole.is_archival?
    assert @hole.muskrats.first.is_archival?

    @hole.archive

    digest = Digest::MD5.hexdigest("#{@hole.class.name}#{@hole.id}")
    assert_equal digest, @hole.archive_number
    assert_equal digest, @hole.muskrats(true).first.archive_number
  end

  test "unarchive unarchives archival records" do
    assert @hole.is_archival?
    assert @hole.muskrats.first.is_archival?

    @hole.archive
    @hole.unarchive

    assert_not @hole.archived?
    assert_not @hole.muskrats(true).first.archived?
  end

  test "test unarchive unarchives only the records associated with the archiving of the head object" do
    assert @hole.is_archival?
    @hole.muskrats << Muskrat.create(:name => "Tenille")
    assert_greater_than @hole.muskrats.size, 1
    assert @hole.muskrats[0].is_archival?
    assert @hole.muskrats[1].is_archival?

    @hole.muskrats.first.archive
    @hole.archive
    @hole.unarchive

    assert     @hole.muskrats(true)[0].archived?
    assert_not @hole.muskrats[1].archived?
  end

  test "test unarchive unarchives only the records associated with the archiving of the head object eveb if you try to unarchive the head object twice" do
    assert @hole.is_archival?
    @hole.muskrats << Muskrat.create(:name => "Tenille")
    assert_greater_than @hole.muskrats.size, 1
    assert @hole.muskrats[0].is_archival?
    assert @hole.muskrats[1].is_archival?

    @hole.muskrats.first.archive
    @hole.archive
    @hole.unarchive
    @hole.unarchive

    assert     @hole.muskrats(true)[0].archived?
    assert_not @hole.muskrats[1].archived?
  end

  test "named scopes work" do
    assert @hole.is_archival?
    @hole.muskrats << Muskrat.create(:name => "Tenille")
    @archived.destroy
    assert_greater_than @hole.muskrats.size, 1
    assert @hole.muskrats.first.is_archival?
    assert @hole.muskrats.last.is_archival?

    assert_equal 2, Hole.unarchived.size
    assert_equal 1, Hole.archived.size
    assert_equal 2, Muskrat.unarchived.size
    assert_equal 0, Muskrat.archived.size

    @hole.muskrats.first.archive
    assert_equal 2, Hole.unarchived.size
    assert_equal 1, Hole.archived.size
    assert_equal 1, Muskrat.unarchived.size
    assert_equal 1, Muskrat.archived.size

    assert @hole.archive
    assert_equal 1, Hole.unarchived.size
    assert_equal 2, Hole.archived.size
    assert_equal 0, Muskrat.unarchived.size
    assert_equal 2, Muskrat.archived.size

    assert_equal 1, Hole.archived_from_archive_number(@hole.archive_number).size
    assert_equal 1, Muskrat.archived_from_archive_number(@hole.archive_number).size

    assert_equal 0, Hole.archived_from_archive_number(@hole.muskrats.first.archive_number).size
    assert_equal 1, Muskrat.archived_from_archive_number(@hole.muskrats.first.archive_number).size
  end

  test "archiving is transactional" do
    ship = Ship.create(:name => "HMS Holly Hawk")
    ship.rats << Rat.create(:name => "Pennyworth")
    assert ship.is_archival?
    assert ship.rats.first.is_archival?
    ship.archive
    assert_not ship.reload.archived?, "If this failed, you might be trying to test on a system that doesn't support nested transactions"
    assert_not ship.rats(true).first.archived?
  end

  test "unarchiving is transactional" do
    ship = Ship.create(:name => "HMS Holly Hawk")
    ship.oranges << Orange.create(:name => "Pennyworth")
    assert ship.is_archival?
    assert ship.oranges.first.is_archival?
    ship.archive
    ship.unarchive
    assert ship.reload.archived?
    assert ship.oranges(true).first.archived?
  end

  test "archiving deeply nested items doesn't blow up" do
    @hole.muskrats.first.fleas << Flea.create(:name => "Wadsworth")
    @hole.archive
    assert @hole.reload.archived?
    assert @hole.muskrats.first.reload.archived?
    assert @hole.muskrats.first.fleas.first.archived?
  end

  test "archiving items with polymorphic associations succeeds" do
    @muskrat = Muskrat.create(:name => "Algernon")
    @tick = Tick.create
    @muskrat.ixodidaes.create(:tick => @tick)
    @muskrat.archive
    assert @muskrat.reload.archived?
  end

  test "unarchiving deeply nested items doesn't blow up" do
    @hole.muskrats.first.fleas << Flea.create(:name => "Wadsworth")
    @hole.archive

    @hole.unarchive
    assert_not @hole.reload.archived?
    assert_not @hole.muskrats.first.reload.archived?
    assert_not @hole.muskrats.first.fleas.first.archived?
  end

  # test against the problem fixed in http://github.com/DarkTatka/acts_as_archival/commit/63d0a2532a15d7a6ab41d081e1591108a5ea9b37
  test "no ambiguous table problem" do
    @hole.muskrats.first.archive
    assert_equal 1, Muskrat.archived.all(:conditions => "holes.number = '14'", :joins => :hole).size
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

  test "entire archiving operation fails if a child fails to archive" do
    assert @hole.archive
    assert @hole.unarchive
    @hole.muskrats.create(:name => "Invalid Rat")
    assert !@hole.archive
    assert @hole.reload.archive_number.blank?
  end

  test "entire unarchiving operation fails if a child fails to unarchive" do
    assert @hole.archive
    @hole.muskrats.create(:name => "Invalid Rat", :archive_number => @hole.archive_number, :archived_at => @hole.archived_at)
    assert !@hole.unarchive
    assert @hole.reload.archive_number.present?
    @hole.muskrats.last.destroy
    assert @hole.unarchive
  end
end
