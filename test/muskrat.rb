class Muskrat < ActiveRecord::Base
  acts_as_archival
  
  belongs_to :hole
  has_many :fleas, :dependent => :destroy
end
