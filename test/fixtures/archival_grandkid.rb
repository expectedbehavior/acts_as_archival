class ArchivalGrandkid < ActiveRecord::Base
  acts_as_archival
  belongs_to :archival_kid
end
