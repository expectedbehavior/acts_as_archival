# name           - string
# archival_id    - integer
# archive_number - string
# archived_at    - datetime
class PgArchival < ActiveRecord::Base
  establish_connection $dbconfig["pg"]
  self.table_name = "archivals"
  acts_as_archival
  has_many :exploders, :dependent => :destroy, :foreign_key => :archival_id, :class_name => "PgExploder"
end
