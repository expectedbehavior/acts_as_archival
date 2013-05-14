module ExpectedBehavior
  module ActsAsArchival
    module AssociationOperation

      class RelatedArchival
        attr_reader :model, :head_archive_number, :options

        def initialize(model, head_archive_number, options = {})
          @model = model
          @head_archive_number = head_archive_number
          @options = options
          @options[:association_conditions] ||= Proc.new { true }
        end

        def execute
          return if options.length == 0
          act_on_all_archival_associations
        end

        protected

        def act_on_all_archival_associations
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
            options[:association_conditions].call(association) &&
            association.options[:through].nil?
        end

        def act_on_a_related_archival(klass, key_name)
          if options[:archive]
            archive_association(klass, key_name)
          elsif options[:unarchive]
            unarchive_association(klass, key_name)
          end
        end

        def archive_association(klass, key_name)
          klass.unarchived.find(:all, :conditions => ["#{key_name} = ?", model.id]).each do |related_record|
            raise ActiveRecord::Rollback unless related_record.archive(head_archive_number)
          end
        end

        def unarchive_association(klass, key_name)
          klass.archived.find(:all, :conditions => ["#{key_name} = ? AND archive_number = ?", model.id, head_archive_number]).each do |related_record|
            raise ActiveRecord::Rollback unless related_record.unarchive(head_archive_number)
          end
        end
      end

    end
  end
end
