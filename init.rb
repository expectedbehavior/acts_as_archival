# frozen_string_literal: true
# Include hook code here
ActiveRecord::Base.send :include, ExpectedBehavior::ActsAsArchivalActiveRecordMethods
ActiveRecord::Base.send :include, ExpectedBehavior::ActsAsArchival
