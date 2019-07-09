# name           - string
# archival_id    - integer
# archive_number - string
# archived_at    - datetime
class AnotherPolysHolder < ActiveRecord::Base

  acts_as_archival

  has_many :polys, dependent: :destroy, as: :archiveable

end
