# frozen_string_literal: true
# archival_id     - integer
# archive_number  - string
# archived_at     - datetime
class Exploder < ActiveRecord::Base
  acts_as_archival
  belongs_to :archival
end
