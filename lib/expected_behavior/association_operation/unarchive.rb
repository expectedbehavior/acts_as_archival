module ExpectedBehavior
  module ActsAsArchival
    module AssociationOperation

      class Unarchive < Base
        def options
          { :unarchive => true }
        end
      end

    end
  end
end
