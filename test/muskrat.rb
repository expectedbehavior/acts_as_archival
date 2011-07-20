class Muskrat < ActiveRecord::Base
  acts_as_archival

  belongs_to :hole
  has_many :fleas, :dependent => :destroy

  has_many :ixodidaes, :as => :warm_blooded, :dependent => :destroy
  has_many :ticks, :through => :ixodidaes

  validate :invalid_for_certain_names

  def invalid_for_certain_names
    self.errors.add(:base, "Bad name!!") if self.name == "Invalid Rat" && !self.new_record?
  end
end
