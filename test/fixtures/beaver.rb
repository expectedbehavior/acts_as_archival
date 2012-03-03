class Beaver < ActiveRecord::Base
  acts_as_archival :readonly_when_archived => true
end
