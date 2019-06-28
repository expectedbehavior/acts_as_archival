require_relative "test_helper"

class RelationsTest < ActiveSupport::TestCase

  test "archive_all! archives all records in an AR Association" do
    for i in 0..2 do
      Archival.create!
    end 

    archivals = Archival.all
    archivals.archive_all!
    assert archivals.first.archived?
    assert archivals.last.archived?
  end

  test "archive_all! archives all records with the same archival number" do
    for i in 0..2 do
      Archival.create!
    end 

    archivals = Archival.all
    archivals.archive_all!
    assert_equal archivals.first.archive_number, archivals.last.archive_number
  end

  test "archive_all! archives children records" do
    for i in 0..2 do
      parent = Archival.create!
      for j in 0..1 do
        parent.archivals.create!
      end
    end

    parents = Archival.all
    parents.archive_all!

    assert parents.first.archivals.first.archived?
    assert parents.first.archivals.last.archived?
  end

  test "unarchive_all! unarchives all records in an AR Assocation" do
    for i in 0..2 do
      Archival.create!
    end 

    archivals = Archival.all
    archivals.archive_all!
    archivals.unarchive_all!
    assert_not archivals.first.archived?
    assert_not archivals.last.archived?
  end

  test "unarchive_all! unarchives children records" do
    for i in 0..2 do
      parent = Archival.create!
      for j in 0..1 do
        parent.archivals.create!
      end
    end

    parents = Archival.all
    parents.archive_all!
    parents.unarchive_all!

    assert_not parents.first.archivals.first.archived?
    assert_not parents.first.archivals.last.archived?
  end

end
