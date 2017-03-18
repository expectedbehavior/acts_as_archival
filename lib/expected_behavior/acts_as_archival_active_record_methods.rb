module ExpectedBehavior
  module ActsAsArchivalActiveRecordMethods

    def self.included(base)
      base.extend ARClassMethods
      base.send :include, ARInstanceMethods
    end

    module ARClassMethods

      def archival?
        included_modules.include?(ExpectedBehavior::ActsAsArchival::InstanceMethods)
      end

      alias_method :is_archival?, :archival?

    end

    module ARInstanceMethods

      def archival?
        self.class.is_archival?
      end

      alias_method :is_archival?, :archival?

    end

  end
end
