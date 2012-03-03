# name           - string
# archive_number - string
# archived_at    - datetime
class Archival < ActiveRecord::Base
  acts_as_archival

  has_many :kids,   :dependent => :destroy
  has_many :plains, :dependent => :destroy
  has_many :independent_kids

end
