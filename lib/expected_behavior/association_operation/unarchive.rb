# frozen_string_literal: true
module ExpectedBehavior
  module ActsAsArchival
    module AssociationOperation
      class Unarchive < Base

        protected

        def act_on_archivals(scope)
          scope.archived.where(archive_number: head_archive_number).find_each do |related_record|
            raise ActiveRecord::Rollback unless related_record.unarchive(head_archive_number)
          end
        end

      end
    end
  end
end
