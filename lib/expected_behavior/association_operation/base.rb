module ExpectedBehavior
  module ActsAsArchival
    module AssociationOperation

      class Base
        attr_reader :model, :head_archive_number

        def initialize(model, head_archive_number)
          @model = model
          @head_archive_number = head_archive_number
        end

        def execute
          each_archivable_association do |association|
            act_on_association(association) if association_conditions_met? association
          end
        end

        protected

        def each_archivable_association
          self.model.class.reflect_on_all_associations.each do |association|
            yield(association) if archivable_association?(association)
          end
        end

        def archivable_association?(association)
          association.macro.to_s =~ /^has/ &&
            association.klass.is_archival? &&
            association.options[:through].nil?
        end

        def association_conditions_met?(association)
          true
        end

        def act_on_association(association)
          association_key = association.respond_to?(:foreign_key) ? association.foreign_key : association.primary_key_name
          association_scope = association.klass.where("#{association_key} = ?", model.id)
          act_on_a_related_archival(association_scope)
        end

        def act_on_a_related_archival(klass, key_name)
          raise NotImplementedError
        end
      end

    end
  end
end
