module ExpectedBehavior
  module ActsAsArchival
    module Operation

      class UnarchiveRelated < Base
        def options
          { :unarchive => true }
        end
      end

    end
  end
end
