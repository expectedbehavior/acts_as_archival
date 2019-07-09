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
          model.class.reflect_on_all_associations.each do |association|
            yield(association) if archivable_association?(association)
          end
        end

        def archivable_association?(association)
          association.macro.to_s =~ /^has/ &&
            association.klass.archival? &&
            association.options[:through].nil?
        end

        def association_conditions_met?(_association)
          true
        end

        def act_on_association(association)
          key = association.respond_to?(:foreign_key) ? association.foreign_key : association.primary_key_name
          scope_conditions = { key => model.id }
          # polymorphic associations need a type so we don't accidentally act on multiple associated objects
          # that have the same ID
          scope_conditions[association.type] = model.class.base_class.name if association.type
          scope = association.klass.where(scope_conditions)
          act_on_archivals(scope)
        end

        def act_on_archivals(_scope)
          raise NotImplementedError.new("The #{self.class} hasn't implemented 'act_on_archivals(scope)'")
        end

      end
    end
  end
end
