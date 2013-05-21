# name           - string
# archived_at    - datetime
class MissingArchiveNumber < ActiveRecord::Base
  acts_as_archival
end
