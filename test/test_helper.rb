# frozen_string_literal: true
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'bundler/setup'
require 'minitest/autorun'

require 'active_record'
require 'assertions'
require 'database_cleaner'

require 'acts_as_archival'

if ActiveSupport::TestCase.respond_to?(:test_order=)
  ActiveSupport::TestCase.test_order = :random
end

def prepare_for_tests
  setup_logging# if ENV["LOGGING_ENABLED"]
  setup_active_record
  setup_database_cleaner
  create_test_tables
  require_test_classes
end

def setup_logging
  require 'logger'
  logfile = File.dirname(__FILE__) + '/debug.log'
  ActiveRecord::Base.logger = Logger.new(logfile)
end

def setup_active_record
  dbconfig_file = File.dirname(__FILE__) + '/database.yml'
  $dbconfig = YAML.load(File.read(dbconfig_file))
end

def setup_database_cleaner
  DatabaseCleaner.strategy = :truncation
  ActiveSupport::TestCase.send(:setup) do
    DatabaseCleaner.clean
  end
end

def create_test_tables
  schema_file = File.dirname(__FILE__) + '/schema.rb'
  puts '** Loading schema for SQLite'
  ActiveRecord::Base.establish_connection($dbconfig['sqlite'])
  load(schema_file) if File.exist?(schema_file)
end

def require_test_classes
  ActiveSupport::Inflector.inflections do |inflect|
    inflect.irregular 'poly', 'polys'
  end

  fixtures = if ActiveRecord::VERSION::MAJOR >= 4
               [:application_record, :application_record_row, :callback_archival_5]
             else
               [:callback_archival_4]
             end

  fixtures += [
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
  ]
  $require_mass_protection = ActiveModel.constants.include?(:MassAssignmentSecurity)
  fixtures << :mass_attribute_protected if $require_mass_protection
  fixtures.each {|test_class_file| require_relative "fixtures/#{test_class_file}"}
end

prepare_for_tests
