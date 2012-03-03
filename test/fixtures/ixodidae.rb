class Ixodidae < ActiveRecord::Base
  acts_as_archival

  belongs_to :tick
  belongs_to :warm_blodded, :polymorphic => true
end
