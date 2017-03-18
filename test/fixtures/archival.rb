# name           - string
# archival_id    - integer
# archive_number - string
# archived_at    - datetime
class Archival < ActiveRecord::Base

  acts_as_archival

  has_many :archivals,          dependent: :destroy
  has_many :archival_kids,      dependent: :destroy
  has_many :archival_grandkids, dependent: :destroy, through: :archival_kids
  has_many :exploders,          dependent: :destroy
  has_many :plains,             dependent: :destroy
  has_many :polys,              dependent: :destroy, as: :archiveable
  has_many :independent_archivals

  scope :bobs, -> { where(name: ["Bob", "Bobby", "Robert"]) }

end
