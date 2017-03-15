class CallbackArchival4 < ActiveRecord::Base
  acts_as_archival

  attr_accessor :set_this_value,
                :pass_callback

  before_archive :set_value,
                 :conditional_callback_passer

  private def set_value
    self.settable_field = set_this_value
  end

  private def conditional_callback_passer
    pass_callback || pass_callback.nil?
  end
end
