# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "acts_as_archival/version"

Gem::Specification.new do |gem|
  gem.name        = "acts_as_archival"
  gem.summary     = %q{Atomic archiving/unarchiving for ActiveRecord-based apps}
  gem.version     = ActsAsArchival::VERSION
  gem.authors     = ["Joel Meador",
                     "Michael Kuehl",
                     "Matthew Gordon",
                     "Vojtech Salbaba",
                     "David Jones",
                     "Dave Woodward",
                     "Miles Sterrett",
                     "James Hill",
                     "Maarten Claes"]
  gem.email       = ["joel@expectedbehavior.com",
                     "michael@expectedbehavior.com",
                     "matt@expectedbehavior.com",
                     "jason@expectedbehavior.com",
                     "tyler@expectedbehavior.com",
                     "nathan@expectedbehavior.com"]
  gem.homepage    = "http://github.com/expectedbehavior/acts_as_archival"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_dependency "activerecord"

  gem.add_development_dependency "appraisal"
  gem.add_development_dependency "assertions-eb"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "mysql2"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "pg"
  gem.add_development_dependency "rr"
  gem.add_development_dependency "database_cleaner"


  gem.description = <<-END
*Atomic archiving/unarchiving for ActiveRecord-based apps*

We had the problem that acts_as_paranoid and similar plugins/gems always work on
a record by record basis and made it very difficult to restore records
atomically (or archive them, for that matter).

Because the archive and unarchive methods are in transactions, and every
archival record involved gets the same archive number upon archiving, you can
easily restore or remove an entire set of records without having to worry about
partial deletion or restoration.

Additionally, other plugins generally screw with how destroy/delete work.  We
don't because we actually want to be able to destroy records.
END
end
