class Ship < ActiveRecord::Base
  acts_as_archival
  has_many :rats, :dependent => :destroy
  has_many :oranges, :dependent => :destroy
end
