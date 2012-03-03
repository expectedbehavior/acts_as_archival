require "acts_as_archival/version"
require "expected_behavior/acts_as_archival"
require "expected_behavior/acts_as_archival_active_record_methods"
ActiveRecord::Base.send :include, ExpectedBehavior::ActsAsArchival
ActiveRecord::Base.send :include, ExpectedBehavior::ActsAsArchivalActiveRecordMethods
