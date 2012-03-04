$:.unshift(File.dirname(__FILE__) + '/../lib')
require "bundler/setup"
require "test/unit"
require "active_record"
require "assertions"
require "database_cleaner"
require "acts_as_archival"

def prepare_for_tests
  setup_logging if ENV["LOGGING_ENABLED"]
  setup_active_record
  setup_database_cleaner
  create_test_tables
  require_test_classes
end

def setup_logging
  require "logger"
  logfile = File.dirname(__FILE__) + "/debug.log"
  ActiveRecord::Base.logger = Logger.new(logfile)
end

def setup_active_record
  dbconfig_file = File.dirname(__FILE__) + "/database.yml"
  dbconfig = YAML.load File.read(dbconfig_file)
  ActiveRecord::Base.establish_connection(dbconfig)
end

def setup_database_cleaner
  DatabaseCleaner.strategy = :truncation
  ActiveSupport::TestCase.send(:setup) do
    DatabaseCleaner.clean
  end
end

def create_test_tables
  schema_file   = File.dirname(__FILE__) + "/schema.rb"
  load(schema_file) if File.exist?(schema_file)
end

def require_test_classes
  ActiveSupport::Inflector.inflections do |inflect|
    inflect.irregular "poly", "polys"
  end

  [:archival,
   :archival_kid,
   :archival_grandkid,
   :independent_archival,
   :exploder,
   :plain,
   :mass_attribute_protected,
   :readonly_when_archived,
   :missing_archived_at,
   :missing_archive_number,
   :poly
  ].each {|test_class_file| require_relative "fixtures/#{test_class_file}"}
end

prepare_for_tests
