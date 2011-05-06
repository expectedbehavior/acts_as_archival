class Muskrat < ActiveRecord::Base
  acts_as_archival
  
  belongs_to :hole
  has_many :fleas, :dependent => :destroy
  
  validate :invalid_for_certain_names
  
  def invalid_for_certain_names
    self.errors.add(:base, "Bad name!!") if self.name == "Invalid Rat" && !self.new_record?
  end
end
