class Hole < ActiveRecord::Base
  acts_as_archival

  # muskrats are archival
  has_many :muskrats, :dependent => :destroy
  # moles are not archival
  has_many :moles, :dependent => :destroy
  # squirrels are archival, but not dependent destroy
  has_many :squirrels
  # fleas belong to muskrats
  has_many :fleas, :through => :muskrats
end
