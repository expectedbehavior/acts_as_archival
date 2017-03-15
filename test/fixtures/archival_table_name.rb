# frozen_string_literal: true
# name           - string
# archive_number - string
# archived_at    - datetime
class ArchivalTableName < ActiveRecord::Base
  self.table_name = "legacy"
  acts_as_archival
end
