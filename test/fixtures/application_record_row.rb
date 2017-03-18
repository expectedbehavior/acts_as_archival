# Rails 5 introduced a new base class, and this is gonna be used in the tests of that
if defined?(ApplicationRecord)
  class ApplicationRecordRow < ApplicationRecord

    acts_as_archival

  end
end
