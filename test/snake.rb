class Snake < ActiveRecord::Base
  acts_as_archival
  attr_accessible :color
end
