module ExpectedBehavior
  module ActsAsArchival
    module AssociationOperation

      class Unarchive < Base

        protected

        def act_on_a_related_archival(klass, key_name)
          klass.archived.find(:all, :conditions => ["#{key_name} = ? AND archive_number = ?", model.id, head_archive_number]).each do |related_record|
            raise ActiveRecord::Rollback unless related_record.unarchive(head_archive_number)
          end
        end

      end

    end
  end
end
