module ExpectedBehavior
  module ActsAsArchival

    require "digest/md5"

    unless defined?(MissingArchivalColumnError) == "constant" && MissingArchivalColumnError.class == Class
      MissingArchivalColumnError = Class.new(ActiveRecord::ActiveRecordError)
    end
    unless defined?(CouldNotArchiveError) == "constant" && CouldNotArchiveError.class == Class
      CouldNotArchiveError = Class.new(ActiveRecord::ActiveRecordError)
    end
    unless defined?(CouldNotUnarchiveError) == "constant" && CouldNotUnarchiveError.class == Class
      CouldNotUnarchiveError = Class.new(ActiveRecord::ActiveRecordError)
    end

    def self.included(base)
      base.extend ActMethods
    end

    module ActMethods

      def acts_as_archival(options = {})
        return if included_modules.include?(InstanceMethods)

        include InstanceMethods

        setup_validations(options)

        setup_scopes

        setup_callbacks
      end

      private def setup_validations(options)
        before_validation :raise_if_not_archival
        validate :readonly_when_archived if options[:readonly_when_archived]
      end

      private def setup_scopes
        scope :archived, -> { where.not(archived_at: nil).where.not(archive_number: nil) }
        scope :unarchived, -> { where(archived_at: nil, archive_number: nil) }
        scope :archived_from_archive_number, (lambda do |head_archive_number|
          where(["archived_at IS NOT NULL AND archive_number = ?", head_archive_number])
        end)
      end

      private def setup_callbacks
        callbackable_actions = %w[archive unarchive]

        setup_activerecord_callbacks(callbackable_actions)

        define_callback_dsl_methods(callbackable_actions)
      end

      private def setup_activerecord_callbacks(callbackable_actions)
        define_callbacks(*[callbackable_actions].flatten)
      end

      private def define_callback_dsl_methods(callbackable_actions)
        callbackable_actions.each do |action|
          %w[before after].each do |callbackable_type|
            define_callback_dsl_method(callbackable_type, action)
          end
        end
      end

      private def define_callback_dsl_method(callbackable_type, action)
        # rubocop:disable Security/Eval
        eval <<-end_callbacks
          unless defined?(#{callbackable_type}_#{action})
            def #{callbackable_type}_#{action}(*args, &blk)
              set_callback(:#{action}, :#{callbackable_type}, *args, &blk)
            end
          end
        end_callbacks
        # rubocop:enable Security/Eval
      end

    end

    module InstanceMethods

      def readonly_when_archived
        readonly_attributes_changed = archived? && changed? && !archived_at_changed? && !archive_number_changed?
        return unless readonly_attributes_changed

        errors.add(:base, "Cannot modify an archived record.")
      end

      def raise_if_not_archival
        missing_columns = []
        missing_columns << "archive_number" unless respond_to?(:archive_number)
        missing_columns << "archived_at" unless respond_to?(:archived_at)
        return if missing_columns.blank?

        raise MissingArchivalColumnError.new("Add '#{missing_columns.join "', '"}' column(s) to '#{self.class.name}' to make it archival")
      end

      def archived?
        !!(archived_at? && archive_number)
      end

      def archive!(head_archive_number = nil)
        execute_archival_action(:archive) do
          unless archived?
            head_archive_number ||= Digest::MD5.hexdigest("#{self.class.name}#{id}")
            archive_associations(head_archive_number)
            self.archived_at = DateTime.now
            self.archive_number = head_archive_number
            save!
          end
        end
      end

      def unarchive!(head_archive_number = nil)
        execute_archival_action(:unarchive) do
          if archived?
            head_archive_number ||= archive_number
            self.archived_at = nil
            self.archive_number = nil
            save!
            unarchive_associations(head_archive_number)
          end
        end
      end

      def archive_associations(head_archive_number)
        AssociationOperation::Archive.new(self, head_archive_number).execute
      end

      def unarchive_associations(head_archive_number)
        AssociationOperation::Unarchive.new(self, head_archive_number).execute
      end

      private def execute_archival_action(action)
        self.class.transaction do
          begin
            success = run_callbacks(action) { yield }
            return !!success
          rescue => e
            handle_archival_action_exception(e)
          end
        end
        false
      end

      private def handle_archival_action_exception(exception)
        ActiveRecord::Base.logger.try(:debug, exception.message)
        ActiveRecord::Base.logger.try(:debug, exception.backtrace)
        raise ActiveRecord::Rollback
      end

    end

  end
end
