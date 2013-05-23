# archival_id     - integer
# archive_number  - string
# archived_at     - datetime
class PgExploder < ActiveRecord::Base
  establish_connection $dbconfig["pg"]
  self.table_name = "exploders"
  acts_as_archival
  belongs_to :pg_archival, :foreign_key => :archival_id
end
