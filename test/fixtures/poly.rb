# archiveable_id   - integer
# archiveable_type - string
# archive_number   - string
# archived_at      - datetime
class Poly < ActiveRecord::Base
  acts_as_archival
  belongs_to :archiveable, polymorphic: true
end
