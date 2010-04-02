require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class ActsAsArchivalTest < ActiveSupport::TestCase
  def setup
    super
    @hole     = Hole.create(:number => 14)
    @muskrat  = @hole.muskrats.create(:name => "Steady Rat")
    @mole     = @hole.moles.create(:name => "Grabowski")
    @archived = Hole.create(:number => 12).archive
  end

  test "including archival throws exceptions if the correct columns aren't in place" do
    assert_raises(ExpectedBehavior::ActsAsArchival::MissingArchivalColumnError) { Kitty.create!(:name => "foo-foo")}
    assert_raises(ExpectedBehavior::ActsAsArchival::MissingArchivalColumnError) { Puppy.create!(:name => "rover")}
  end

  test "archival class responds correctly to 'is_archival?'" do
    assert @hole.class.is_archival?
    assert_not Mole.is_archival?
  end
  
  test "archival object responds correctly to 'is_archival?'" do
    mole = Mole.create(:name => "Mittens")
    assert @hole.is_archival?
    assert_not mole.is_archival?
  end
  
  test "archive on archived object doesn't alter the archive_number" do
    assert @hole.is_archival?
    initial_number = @hole.archive
    second_number = @hole.reload.archive
    assert_equal initial_number, second_number
  end
  
  test "archive sets archived_at" do
    assert @hole.is_archival?
    @hole.archive
    assert_not_nil @hole.reload.archived_at
  end
  
  test "archive returns the object being archived for chaining" do
    assert @hole.is_archival?
    id = @hole.id
    test = @hole.archive.reload.id
    assert_equal id, test
  end
  
  test "unarchive returns the object being unarchived for chaining" do
    assert @hole.is_archival?
    id = @archived.id
    test = @archived.unarchive.id
    assert_equal id, test
  end
  
  test "archive sets archived_at to the time of archiving" do
    assert @hole.is_archival?
    before = DateTime.now
    @hole.archive
    sleep(0.001)
    after = DateTime.now
    assert_between before, after, @hole.archived_at
  end
  
  test "archive sets the archive number to the md5 hexdigest for the model and id that is archived" do
    assert @hole.class.is_archival?
    @hole.archive
    assert_equal Digest::MD5.hexdigest("#{@hole.class.name}#{@hole.id}"), @hole.archive_number
  end
  
  test "archive archives the record" do
    assert @hole.is_archival?
    @hole.archive
    assert @hole.archived?
  end
  
  test "archive archives 'has_' associated archival objects that are dependent destroy" do
    assert @hole.class.is_archival?
    assert @hole.muskrats.first.class.is_archival?

    @hole.archive
    
    assert @hole.reload.archived?
    assert @hole.muskrats(true).first.archived?
  end
  
  test "archive does not archive 'has_' associated archival objects that are not dependent destroy" do 
    @hole.squirrels.create(:name => "Rocky")
    
    @hole.archive
    
    assert @hole.reload.archived?
    assert_not @hole.squirrels(true).first.archived?
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
    
    @hole.archive.unarchive
    
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
    @hole.archive.unarchive
    
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
    @hole.archive.unarchive.unarchive
    
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

    assert_equal 1, Hole.unarchived.size
    assert_equal 0, Hole.archived.size
    assert_equal 2, Muskrat.unarchived.size
    assert_equal 0, Muskrat.archived.size
    
    @hole.muskrats.first.archive
    assert_equal 1, Hole.unarchived.size
    assert_equal 0, Hole.archived.size
    assert_equal 1, Muskrat.unarchived.size
    assert_equal 1, Muskrat.archived.size
    
    @hole.archive
    assert_equal 0, Hole.unarchived.size
    assert_equal 1, Hole.archived.size
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
    ship.archive.unarchive
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
end
