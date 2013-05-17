module ExpectedBehavior
  module ActsAsArchival
    require 'digest/md5'

    MissingArchivalColumnError = Class.new(ActiveRecord::ActiveRecordError) unless defined?(MissingArchivalColumnError) == 'constant' && MissingArchivalColumnError.class == Class
    CouldNotArchiveError = Class.new(ActiveRecord::ActiveRecordError) unless defined?(CouldNotArchiveError) == 'constant' && CouldNotArchiveError.class == Class
    CouldNotUnarchiveError = Class.new(ActiveRecord::ActiveRecordError) unless defined?(CouldNotUnarchiveError) == 'constant' && CouldNotUnarchiveError.class == Class

    def self.included(base)
      base.extend ActMethods
    end

    module ActMethods
      def acts_as_archival(options = { })
        unless included_modules.include? InstanceMethods
          include InstanceMethods

          before_validation :raise_if_not_archival
          validate :readonly_when_archived if options[:readonly_when_archived]

          scope :archived, lambda { where %Q{#{self.table_name}.archived_at IS NOT NULL AND #{self.table_name}.archive_number IS NOT NULL} }
          scope :unarchived, lambda { where(:archived_at => nil, :archive_number => nil) }
          scope :archived_from_archive_number, lambda { |head_archive_number| where(['archived_at IS NOT NULL AND archive_number = ?', head_archive_number]) }

          callbacks = ['archive','unarchive']
          define_callbacks *[callbacks, {:terminator => 'result == false'}].flatten
          callbacks.each do |callback|
            eval <<-end_callbacks
              def before_#{callback}(*args, &blk)
                set_callback(:#{callback}, :before, *args, &blk)
              end
              def after_#{callback}(*args, &blk)
                set_callback(:#{callback}, :after, *args, &blk)
              end
            end_callbacks
          end
        end
      end

    end

    module InstanceMethods

      def readonly_when_archived
        if self.archived? && self.changed? && !self.archived_at_changed? && !self.archive_number_changed?
          self.errors.add(:base, "Cannot modify an archived record.")
        end
      end

      def raise_if_not_archival
        missing_columns = []
        missing_columns << "archive_number" unless self.respond_to?(:archive_number)
        missing_columns << "archived_at" unless self.respond_to?(:archived_at)
        raise MissingArchivalColumnError.new("Add '#{missing_columns.join "', '"}' column(s) to '#{self.class.name}' to make it archival") unless missing_columns.blank?
      end

      def archived?
        self.archived_at? && self.archive_number
      end

      def archive(head_archive_number=nil)
        self.class.transaction do
          begin
            run_callbacks :archive do
              unless self.archived?
                head_archive_number ||= Digest::MD5.hexdigest("#{self.class.name}#{self.id}")
                self.archive_associations(head_archive_number)
                self.archived_at = DateTime.now
                self.archive_number = head_archive_number
                self.save!
              end
            end
            return true
          rescue => e
            ActiveRecord::Base.logger.try(:debug, e.message)
            ActiveRecord::Base.logger.try(:debug, e.backtrace)
            raise ActiveRecord::Rollback
          end
        end
        false
      end

      def unarchive(head_archive_number=nil)
        self.class.transaction do
          begin
            run_callbacks :unarchive do
              if self.archived?
                head_archive_number ||= self.archive_number
                self.archived_at = nil
                self.archive_number = nil
                self.save!
                self.unarchive_associations(head_archive_number)
              end
            end
            return true
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
