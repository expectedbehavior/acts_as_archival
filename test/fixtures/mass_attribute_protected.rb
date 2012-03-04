class MassAttributeProtected < ActiveRecord::Base
  acts_as_archival
  attr_accessible :name
end
