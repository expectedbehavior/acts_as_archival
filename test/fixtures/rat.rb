class Rat < ActiveRecord::Base
  acts_as_archival
  belongs_to :ship

  alias :orig_archive :archive

  def archive(holy_hand_grenade)
    raise "you'll sink with the ship!"
  end
end
