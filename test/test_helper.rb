$:.unshift(File.dirname(__FILE__) + '/../lib')
#RAILS_ROOT = File.dirname(__FILE__)

require "rubygems"
require "active_record"
require "#{File.dirname(__FILE__)}/../lib/expected_behavior/acts_as_archival.rb"
require "#{File.dirname(__FILE__)}/../lib/expected_behavior/acts_as_archival_active_record_methods.rb"
require "#{File.dirname(__FILE__)}/../init"


ENV["RAILS_ENV"] = "test"
# "/aaa_test_app/config/environment",
# "/../../../../config/environment",
["/aaa_test_app/config/environment",
#  "/../lib/expected_behavior/acts_as_archival_active_record_methods",
#  "/../lib/expected_behavior/acts_as_archival",
 "/local_test_helper"
].each do |file_to_load|
  require File.expand_path(File.dirname(__FILE__) + file_to_load)
end

require 'rails/test_help'
require 'assertions'

%w(hole mole muskrat squirrel kitty puppy ship rat orange flea snake beaver tick ixodidae).each do |a|
  require File.expand_path(File.dirname(__FILE__) + "/" + a)
end

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  self.use_instantiated_fixtures  = false

  fixtures :all
end
