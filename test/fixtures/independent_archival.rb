# frozen_string_literal: true
# name           - string
# archival_id    - integer
# archive_number - string
# archived_at    - datetime
class IndependentArchival < ActiveRecord::Base
  acts_as_archival
  belongs_to :archival
end
