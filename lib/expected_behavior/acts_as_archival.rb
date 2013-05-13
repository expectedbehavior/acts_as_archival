module ExpectedBehavior
  module ActsAsArchival
    require 'digest/md5'

    ARCHIVED_CONDITIONS = lambda { |zelf| %Q{#{zelf.to_s.tableize}.archived_at IS NOT NULL AND #{zelf.to_s.tableize}.archive_number IS NOT NULL} }
    UNARCHIVED_CONDITIONS = { :archived_at => nil, :archive_number => nil }

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

          scope :archived, :conditions => ARCHIVED_CONDITIONS.call(self)
          scope :unarchived, :conditions => UNARCHIVED_CONDITIONS
          scope :archived_from_archive_number, lambda { |head_archive_number| {:conditions => ['archived_at IS NOT NULL AND archive_number = ?', head_archive_number] } }

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
            run_callbacks :unarchive, :before
            if self.archived?
              head_archive_number ||= self.archive_number
              self.archived_at = nil
              self.archive_number = nil
              self.save!
              self.unarchive_associations(head_archive_number)
            end
            run_callbacks :unarchive, :after
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
        RelatedArchiveOperation.new(self, head_archive_number).execute
      end

      def unarchive_associations(head_archive_number)
        RelatedUnarchiveOperation.new(self, head_archive_number).execute
      end

      class RelatedArchiveOperation
        attr_reader :model, :head_archive_number
        def initialize(model, head_archive_number)
          @model = model
          @head_archive_number = head_archive_number
        end

        def execute
          act_only_on_dependent_destroy_associations = Proc.new {|association| association.options[:dependent] == :destroy}
          options = { :archive => true, :association_options => act_only_on_dependent_destroy_associations }
          RelatedArchivalOperation.new(model, head_archive_number, options).execute
        end
      end

      class RelatedUnarchiveOperation
        attr_reader :model, :head_archive_number
        def initialize(model, head_archive_number)
          @model = model
          @head_archive_number = head_archive_number
        end

        def execute
          RelatedArchivalOperation.new(model, head_archive_number, :unarchive => true).execute
        end
      end

      class RelatedArchivalOperation
        attr_reader :model, :head_archive_number, :options

        def initialize(model, head_archive_number, options = {})
          @model = model
          @head_archive_number = head_archive_number
          @options = options
        end

        def execute
          act_on_all_archival_associations
        end

        def act_on_all_archival_associations
          return if options.length == 0
          options[:association_options] ||= Proc.new { true }
          self.model.class.reflect_on_all_associations.each do |association|
            if should_act_on_association? association
              association_key = association.respond_to?(:foreign_key) ? association.foreign_key : association.primary_key_name
              act_on_a_related_archival(association.klass, association_key)
            end
          end
        end

        def should_act_on_association?(association)
          association.macro.to_s =~ /^has/ &&
            association.klass.is_archival? &&
            options[:association_options].call(association) &&
            association.options[:through].nil?
        end

        def act_on_a_related_archival(klass, key_name)
          return if options.length == 0 || (!options[:archive] && !options[:unarchive])
          if options[:archive]
            klass.unarchived.find(:all, :conditions => ["#{key_name} = ?", model.id]).each do |related_record|
              raise ActiveRecord::Rollback unless related_record.archive(head_archive_number)
            end
          else
            klass.archived.find(:all, :conditions => ["#{key_name} = ? AND archive_number = ?", model.id, head_archive_number]).each do |related_record|
              raise ActiveRecord::Rollback unless related_record.unarchive(head_archive_number)
            end
          end
        end
      end

    end
  end
end
