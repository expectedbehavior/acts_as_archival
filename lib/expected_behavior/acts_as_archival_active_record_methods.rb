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

      # rubocop:disable Style/PredicateName
      def is_archival?
        ActiveSupport::Deprecation.warn(".is_archival? is deprecated in favor of .archival?")
        archival?
      end
      # rubocop:enable Style/PredicateName

    end

    module ARInstanceMethods

      def archival?
        self.class.archival?
      end

      # rubocop:disable Style/PredicateName
      def is_archival?
        ActiveSupport::Deprecation.warn("#is_archival? is deprecated in favor of #archival?")
        archival?
      end
      # rubocop:enable Style/PredicateName

    end

  end
end
