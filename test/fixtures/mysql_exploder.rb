# archival_id     - integer
# archive_number  - string
# archived_at     - datetime
class MysqlExploder < ActiveRecord::Base
  establish_connection $dbconfig["mysql"]
  self.table_name = "exploders"
  acts_as_archival
  belongs_to :mysql_archival, :foreign_key => :archival_id
end
