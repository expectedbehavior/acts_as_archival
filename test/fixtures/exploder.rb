class Exploder < ActiveRecord::Base
  acts_as_archival

  belongs_to :archival
end
