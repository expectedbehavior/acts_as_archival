$:.unshift(File.dirname(__FILE__) + '/../lib')
require "bundler/setup"
require "test/unit"
require "active_record"
require "assertions"
require "logger"
require "pry"
require "database_cleaner"

require "acts_as_archival"

database_config = File.dirname(__FILE__) + "/database.yml"
logfile         = File.dirname(__FILE__) + "/debug.log"
schema_file     = File.dirname(__FILE__) + "/schema.rb"

dbconfig = YAML.load File.read(database_config)

ActiveRecord::Base.logger = Logger.new(logfile)
ActiveRecord::Base.establish_connection(dbconfig)
load(schema_file) if File.exist?(schema_file)

%w(archival independent_archival exploder plain mass_attribute_protected readonly_when_archived missing_archived_at missing_archive_number hole mole muskrat squirrel ship rat orange flea snake beaver tick ixodidae).each do |test_class_file|
  require_relative "fixtures/#{test_class_file}"
end

DatabaseCleaner.strategy = :truncation

class ActiveSupport::TestCase
  def setup
    DatabaseCleaner.clean
  end
end
