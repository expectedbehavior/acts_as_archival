# frozen_string_literal: true
require_relative 'test_helper'
require 'rr'

class TransactionTest < ActiveSupport::TestCase

  test 'archiving is transactional' do
    archival = Archival.create!
    exploder = archival.exploders.create!
    any_instance_of(Exploder) do |canary|
      stub(canary).archive { raise 'Rollback Imminent' }
    end
    archival.archive

    assert_not archival.archived?, "If this failed, you might be trying to test on a system that doesn't support nested transactions"
    assert_not exploder.reload.archived?
  end

  test 'unarchiving is transactional' do
    archival = Archival.create!
    exploder = archival.exploders.create!
    any_instance_of(Exploder) do |canary|
      stub(canary).unarchive { raise 'Rollback Imminent' }
    end
    archival.archive
    archival.unarchive

    assert archival.reload.archived?
    assert exploder.reload.archived?
  end
end
