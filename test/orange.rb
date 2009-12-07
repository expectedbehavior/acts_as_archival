class Orange < ActiveRecord::Base
  acts_as_archival
  belongs_to :ship

  alias :orig_unarchive :unarchive

  def unarchive(holy_hand_grenade)
    raise "scurvy!"
  end
end
