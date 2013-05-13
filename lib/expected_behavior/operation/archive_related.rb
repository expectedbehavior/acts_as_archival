module ExpectedBehavior
  module ActsAsArchival
    module Operation

      class ArchiveRelated < Base
        def options
          {
            :archive => true,
            :association_conditions => Proc.new { |association|
              association.options[:dependent] == :destroy
            }
          }
        end
      end

    end
  end
end
