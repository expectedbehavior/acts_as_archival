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
            run_callbacks :archive, :before
            unless self.archived?
              head_archive_number ||= Digest::MD5.hexdigest("#{self.class.name}#{self.id}")
              self.archive_associations(head_archive_number)
              self.archived_at = DateTime.now
              self.archive_number = head_archive_number
              self.save!
            end
            run_callbacks :archive, :after
            return true
          rescue
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
            # output errors. Should not fail silently
            puts e.message
            puts e.backtrace
            raise ActiveRecord::Rollback
          end
        end
        false
      end

      def archive_associations(head_archive_number)
        act_only_on_dependent_destroy_associations = Proc.new {|association| association.options[:dependent] == :destroy}
        act_on_all_archival_associations(head_archive_number, :archive => true, :association_options => act_only_on_dependent_destroy_associations)
      end

      def unarchive_associations(head_archive_number)
        act_on_all_archival_associations(head_archive_number, :unarchive => true)
      end

      def act_on_all_archival_associations(head_archive_number, options={})
        return if options.length == 0
        options[:association_options] ||= Proc.new { true }
        self.class.reflect_on_all_associations.each do |association|
          if (association.macro.to_s =~ /^has/ && association.klass.is_archival? &&
              options[:association_options].call(association) &&
              association.options[:through].nil?) then

            if association.respond_to? :foreign_key then
              association_key = association.foreign_key
            elsif association.respond_to? :primary_key_name then
              association_key = association.primary_key_name
            end
              act_on_a_related_archival(association.klass, association_key, id, head_archive_number, options)
          end
        end
      end

      def act_on_a_related_archival(klass, key_name, id, head_archive_number, options={})
        return if options.length == 0 || (!options[:archive] && !options[:unarchive])
        if options[:archive]
          klass.unarchived.find(:all, :conditions => ["#{key_name} = ?", id]).each do |related_record|
            unless related_record.archive(head_archive_number)
              raise ActiveRecord::Rollback
            end
          end
        else
          klass.archived.find(:all, :conditions => ["#{key_name} = ? AND archive_number = ?", id, head_archive_number]).each do |related_record|
            unless related_record.unarchive(head_archive_number)
              raise ActiveRecord::Rollback
            end
          end
        end
      end
    end
  end
end
