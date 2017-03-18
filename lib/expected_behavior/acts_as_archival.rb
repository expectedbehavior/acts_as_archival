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
      # rubocop:disable Metrics/MethodLength
      def acts_as_archival(options = {})
        return if included_modules.include?(InstanceMethods)

        include InstanceMethods

        before_validation :raise_if_not_archival
        validate :readonly_when_archived if options[:readonly_when_archived]

        scope :archived, -> { where.not(archived_at: nil, archive_number: nil) }
        scope :unarchived, -> { where(archived_at: nil, archive_number: nil) }
        scope :archived_from_archive_number, (lambda do |head_archive_number|
          where(["archived_at IS NOT NULL AND archive_number = ?", head_archive_number])
        end)

        callbacks = ["archive", "unarchive"]
        if ActiveSupport::VERSION::MAJOR >= 5
          define_callbacks(*[callbacks].flatten)
        elsif ActiveSupport::VERSION::MAJOR >= 4
          define_callbacks(*[callbacks, { terminator: ->(_, result) { result == false } }].flatten)
        end
        callbacks.each do |callback|
          # rubocop:disable Security/Eval
          eval <<-end_callbacks
            unless defined?(before_#{callback})
              def before_#{callback}(*args, &blk)
                set_callback(:#{callback}, :before, *args, &blk)
              end
            end
            unless defined?(after_#{callback})
              def after_#{callback}(*args, &blk)
                set_callback(:#{callback}, :after, *args, &blk)
              end
            end
          end_callbacks
        end
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

      def archive(head_archive_number = nil)
        self.class.transaction do
          begin
            success = run_callbacks(:archive) do
              unless archived?
                head_archive_number ||= Digest::MD5.hexdigest("#{self.class.name}#{id}")
                archive_associations(head_archive_number)
                self.archived_at = DateTime.now
                self.archive_number = head_archive_number
                save!
              end
            end
            return !!success
          rescue => e
            ActiveRecord::Base.logger.try(:debug, e.message)
            ActiveRecord::Base.logger.try(:debug, e.backtrace)
            raise ActiveRecord::Rollback
          end
        end
        false
      end

      def unarchive(head_archive_number = nil)
        self.class.transaction do
          begin
            success = run_callbacks(:unarchive) do
              if archived?
                head_archive_number ||= archive_number
                self.archived_at = nil
                self.archive_number = nil
                save!
                unarchive_associations(head_archive_number)
              end
            end
            return !!success
          rescue => e
            ActiveRecord::Base.logger.try(:debug, e.message)
            ActiveRecord::Base.logger.try(:debug, e.backtrace)
            raise ActiveRecord::Rollback
          end
        end
        false
      end

      def archive_associations(head_archive_number)
        AssociationOperation::Archive.new(self, head_archive_number).execute
      end

      def unarchive_associations(head_archive_number)
        AssociationOperation::Unarchive.new(self, head_archive_number).execute
      end
    end
  end
end
