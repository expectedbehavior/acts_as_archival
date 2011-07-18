class Tick < ActiveRecord::Base
  acts_as_archival

  has_many :ixodidae # Here the whole join-table polymorph analogy totally breaks down... sorry
end
