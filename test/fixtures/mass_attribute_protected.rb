# name           - string
# archive_number - string
# archived_at    - datetime
class MassAttributeProtected < ActiveRecord::Base
  acts_as_archival
  attr_accessible :name
end
