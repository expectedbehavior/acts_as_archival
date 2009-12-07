module Test
  module Unit
    module Assertions
      public
      def assert_between(lhs1, lhs2, rhs, message="")
        if lhs1 == lhs2
          full_message = build_message(message, "Gave the same value for both sides of range. <?> was not equal to <?>", lhs1, rhs)
          assert_block(full_message) { lhs1 == rhs }
        else
          lower  = lhs1 < lhs2 ? lhs1 : lhs2
          higher = lhs1 < lhs2 ? lhs2 : lhs1
          full_message = build_message(message, "<?> was not between <?> and <?>", rhs, lower, higher)
          assert_block(full_message) { (lower..higher).include?(rhs)}
        end
      end
    end
  end
end
