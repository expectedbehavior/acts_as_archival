# frozen_string_literal: true
# archival_kid_id - integer
# archive_number  - string
# archived_at     - datetime
class ArchivalGrandkid < ActiveRecord::Base
  acts_as_archival
  belongs_to :archival_kid
end
