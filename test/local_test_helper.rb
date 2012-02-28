ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

load(File.dirname(__FILE__) + "/schema.rb") if File.exist?(File.dirname(__FILE__) + "/schema.rb")
