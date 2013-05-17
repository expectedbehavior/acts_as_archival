require "acts_as_archival/version"

require "expected_behavior/association_operation/base"
require "expected_behavior/association_operation/archive"
require "expected_behavior/association_operation/unarchive"

require "expected_behavior/acts_as_archival"
require "expected_behavior/acts_as_archival_active_record_methods"

ActiveRecord::Base.send :include, ExpectedBehavior::ActsAsArchival
ActiveRecord::Base.send :include, ExpectedBehavior::ActsAsArchivalActiveRecordMethods
