class Flea < ActiveRecord::Base
  acts_as_archival

  belongs_to :muskrat
end
