# name           - string
# archival_id    - integer
# archive_number - string
# archived_at    - datetime
class IndependentKid < ActiveRecord::Base
  acts_as_archival

  belongs_to :archival
end
