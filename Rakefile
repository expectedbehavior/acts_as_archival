#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Default: run all available test suites."
task default: [:rubocop, :test]

desc "Test the acts_as_archival plugin."
Rake::TestTask.new(:test) do |t|
  t.libs    << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end
