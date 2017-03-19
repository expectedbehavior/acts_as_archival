$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib")
require "bundler/setup"
require "minitest/autorun"
require "minitest/pride"

require "active_record"
require "assertions"
require "database_cleaner"

require "acts_as_archival"

if ActiveSupport::TestCase.respond_to?(:test_order=)
  ActiveSupport::TestCase.test_order = :random
end

def prepare_for_tests
  setup_logging
  setup_database_cleaner
  create_test_tables
  require_test_classes
end

def setup_logging
  require "logger"
  logfile = File.dirname(__FILE__) + "/debug.log"
  ActiveRecord::Base.logger = Logger.new(logfile)
end

def setup_database_cleaner
  DatabaseCleaner.strategy = :truncation
  ActiveSupport::TestCase.send(:setup) do
    DatabaseCleaner.clean
  end
end

def sqlite_config
  {
    adapter: "sqlite3",
    database: "aaa_test.sqlite3",
    pool: 5,
    timeout: 5000
  }
end

def create_test_tables
  schema_file = File.dirname(__FILE__) + "/schema.rb"
  puts "** Loading schema for SQLite"
  ActiveRecord::Base.establish_connection(sqlite_config)
  load(schema_file) if File.exist?(schema_file)
end

BASE_FIXTURE_CLASSES = [
  :archival,
  :archival_kid,
  :archival_grandkid,
  :archival_table_name,
  :exploder,
  :independent_archival,
  :missing_archived_at,
  :missing_archive_number,
  :plain,
  :poly,
  :readonly_when_archived
].freeze

RAILS_4_FIXTURE_CLASSES = [
  :callback_archival_4
].freeze

RAILS_5_FIXTURE_CLASSES = [
  :application_record,
  :application_record_row,
  :callback_archival_5
].freeze

def require_test_classes
  ActiveSupport::Inflector.inflections do |inflect|
    inflect.irregular "poly", "polys"
  end

  fixtures = if ActiveRecord::VERSION::MAJOR >= 4
               RAILS_5_FIXTURE_CLASSES + BASE_FIXTURE_CLASSES
             else
               RAILS_4_FIXTURE_CLASSES + BASE_FIXTURE_CLASSES
             end

  fixtures += BASE_FIXTURE_CLASSES
  fixtures.each { |test_class_file| require_relative "fixtures/#{test_class_file}" }
end

prepare_for_tests
