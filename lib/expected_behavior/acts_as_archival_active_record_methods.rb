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

    end

    module ARInstanceMethods

      def archival?
        self.class.archival?
      end

    end

    module ARRelationMethods

      def archive_all!
        error_message = "The #{klass} must implement 'act_on_archivals' in order to call `archive_all!`"
        raise NotImplementedError.new(error_message) unless archival?

        head_archive_number = Digest::MD5.hexdigest("#{klass}#{Time.now.utc.to_i}")
        each { |record| record.archive!(head_archive_number) }.tap { reset }
      end

      def unarchive_all!
        error_message = "The #{klass} must implement 'act_on_archivals' in order to call `unarchive_all!`"
        raise NotImplementedError.new(error_message) unless archival?

        each(&:unarchive!).tap { reset }
      end

    end

  end
end
