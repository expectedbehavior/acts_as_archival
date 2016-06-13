require_relative "test_helper"

class AssociationsTest < ActiveSupport::TestCase
  test "archive archives 'has_' associated archival objects that are dependent destroy" do
    archival = Archival.create!
    child = archival.archivals.create!
    archival.archive

    assert archival.reload.archived?
    assert child.reload.archived?
  end

  test "archive acts on all objects in the 'has_' relationship" do
    archival = Archival.create!
    children = [archival.archivals.create!, archival.archivals.create!]
    archival.archive

    assert archival.reload.archived?
    assert children.map(&:reload).all?(&:archived?)
  end

  test "archive acts on all objects in the has_ relationship without persistence" do
    archival = Archival.create!
    children = [archival.archivals.create!, archival.archivals.create!]
    archival.archive(nil, false)

    assert_equal true, archival.archived?, 'owner is archived'
    assert_equal true, children.all?(&:archived?), 'children are archived'

    assert_equal false, archival.reload.archived?, 'owner archiving not persisted'
    assert_equal false, children.map(&:reload).all?(&:archived?), 'children archiving not persisted'
  end

  test "archive does not act on already archived objects" do
    archival = Archival.create!
    archival.archivals.create!
    prearchived_child = archival.archivals.create!
    prearchived_child.archive
    archival.archive

    assert_not_equal archival.archive_number, prearchived_child.reload.archive_number
  end

  test "archive does not archive 'has_' associated archival objects that are not dependent destroy" do
    archival = Archival.create!
    non_dependent_child = archival.independent_archivals.create!
    archival.archive

    assert     archival.reload.archived?
    assert_not non_dependent_child.reload.archived?
  end

  test "archive doesn't do anything to associated dependent destroy models that are non-archival" do
    archival = Archival.create!
    plain = archival.plains.create!
    archival.archive

    assert archival.archived?
    assert plain.reload
  end

  test "archive sets the object hierarchy to all have the same archive_number" do
    archival = Archival.create!
    child = archival.archivals.create!
    archival.archive
    expected_digest = Digest::MD5.hexdigest("Archival#{archival.id}")

    assert_equal expected_digest, archival.archive_number
    assert_equal expected_digest, child.reload.archive_number
  end

  test "unarchive acts on child objects" do
    archival = Archival.create!
    child = archival.archivals.create!
    archival.archive
    archival.unarchive

    assert_not archival.archived?
    assert_not child.reload.archived?
  end

  test "unarchive does not act on already archived objects" do
    archival = Archival.create!
    child = archival.archivals.create!
    prearchived_child = archival.archivals.create!
    prearchived_child.archive
    archival.archive
    archival.unarchive

    assert_not archival.archived?
    assert_not child.reload.archived?
    assert     prearchived_child.reload.archived?
  end

  test "unarchive acts on 'has_' associated non-dependent_destroy objects" do
    archival = Archival.create!
    independent = archival.independent_archivals.create!
    archival.archive
    independent.archive(archival.archive_number)
    archival.unarchive

    assert_not archival.reload.archived?
    assert_not independent.reload.archived?
  end

  test "unarchive doesn't unarchive associated objects if the head object is already unarchived" do
    archival = Archival.create!
    prearchived_child = archival.archivals.create!
    prearchived_child.archive
    archival.unarchive

    assert prearchived_child.reload.archived?
  end
end
