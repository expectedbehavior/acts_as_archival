# frozen_string_literal: true
module ExpectedBehavior
  module ActsAsArchivalActiveRecordMethods
    def self.included(base)
      base.extend ARClassMethods
      base.send :include, ARInstanceMethods
    end

    module ARClassMethods
      def is_archival?
        self.included_modules.include?(ExpectedBehavior::ActsAsArchival::InstanceMethods)
      end
    end

    module ARInstanceMethods
      def is_archival?
        self.class.is_archival?
      end
    end
  end
end
