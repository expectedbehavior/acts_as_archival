# name           - string
# archival_id    - integer
# archive_number - string
# archived_at    - datetime
class ExplodeOnArchiveKid < ActiveRecord::Base
  acts_as_archival

  belongs_to :archival

  def archive(*)
    raise "ROLLBACK IMMINENT"
  end
end
