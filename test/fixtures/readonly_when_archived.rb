# name           - string
# archive_number - string
# archived_at    - datetime
class ReadonlyWhenArchived < ActiveRecord::Base

  acts_as_archival readonly_when_archived: true

end
