module ExpectedBehavior
  module ActsAsArchival
    module Operation

      class Base
        attr_reader :model, :head_archive_number

        def initialize(model, head_archive_number)
          @model = model
          @head_archive_number = head_archive_number
        end

        def execute
          Operation::RelatedArchival.new(model, head_archive_number, options).execute
        end

        def options
          {}
        end
      end

    end
  end
end
