require "acts_as_archival/version"

require "expected_behavior/association_operation/base"
require "expected_behavior/association_operation/archive"
require "expected_behavior/association_operation/unarchive"

require "expected_behavior/acts_as_archival"
require "expected_behavior/acts_as_archival_active_record_methods"

# This assumes a fully Rails 5 compatible set of ActiveRecord models
if defined?(ApplicationRecord)
  ApplicationRecord.send :include, ExpectedBehavior::ActsAsArchival
  ApplicationRecord.send :include, ExpectedBehavior::ActsAsArchivalActiveRecordMethods
else
  ActiveRecord::Base.send :include, ExpectedBehavior::ActsAsArchival
  ActiveRecord::Base.send :include, ExpectedBehavior::ActsAsArchivalActiveRecordMethods
end

ActiveRecord::Relation.send :include, ExpectedBehavior::ActsAsArchivalActiveRecordMethods::ARRelationMethods