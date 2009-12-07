class Hole < ActiveRecord::Base
  acts_as_archival

  # muskrats are permanent
  has_many :muskrats, :dependent => :destroy
  # moles are not permanent
  has_many :moles, :dependent => :destroy
  # squirrels are archival, but not dependent destroy
  has_many :squirrels
end
