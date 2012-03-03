$:.unshift(File.dirname(__FILE__) + '/../lib')
require "bundler/setup"
require "test/unit"
require "active_record"
require "assertions"
require "logger"
require "pry"

require "acts_as_archival"

database_config = File.dirname(__FILE__) + "/database.yml"
logfile         = File.dirname(__FILE__) + "/debug.log"
schema_file     = File.dirname(__FILE__) + "/schema.rb"

dbconfig = YAML.load File.read(database_config)

ActiveRecord::Base.logger = Logger.new(logfile)
ActiveRecord::Base.establish_connection(dbconfig)
load(schema_file) if File.exist?(schema_file)

%w(hole mole muskrat squirrel kitty puppy ship rat orange flea snake beaver tick ixodidae).each do |test_class_file|
  require_relative test_class_file
end

class ActiveSupport::TestCase
  use_transactional_fixtures = true
  use_instantiated_fixtures  = false
end
