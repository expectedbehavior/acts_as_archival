module ExpectedBehavior
  module ActsAsArchival
    module Operation

      class ArchiveRelated < Base
        def options
          {
            :archive => true,
            :association_options => Proc.new { |association|
              association.options[:dependent] == :destroy
            }
          }
        end
      end

    end
  end
end
