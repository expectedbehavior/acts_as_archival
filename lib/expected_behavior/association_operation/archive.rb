module ExpectedBehavior
  module ActsAsArchival
    module AssociationOperation

      class Archive < Base

        protected

        def act_on_a_related_archival(klass, key_name)
          klass.unarchived.find(:all, :conditions => ["#{key_name} = ?", model.id]).each do |related_record|
            raise ActiveRecord::Rollback unless related_record.archive(head_archive_number)
          end
        end

        def association_conditions_met?(association)
          association.options[:dependent] == :destroy
        end
      end

    end
  end
end
