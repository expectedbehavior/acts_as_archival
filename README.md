# ActsAsArchival

[![Build Status](https://travis-ci.org/expectedbehavior/acts_as_archival.svg?branch=master)](https://travis-ci.org/expectedbehavior/acts_as_archival)
[![Gem Version](https://badge.fury.io/rb/acts_as_archival.svg)](https://badge.fury.io/rb/acts_as_archival)

Atomically archive object trees in your activerecord models.

We had the problem that acts_as_paranoid and similar plugins/gems
always work on a record-by-record basis and made it very difficult to
restore records atomically (or archive them, for that matter).

Because the archive and unarchive methods are in transactions, and
every archival record involved gets the same archive number upon
archiving, you can easily restore or remove an entire set of records
without having to worry about partial deletion or restoration.

Additionally, other plugins generally screw with how
`destroy`/`delete` work.  We don't because we actually want to be able
to destroy records.

## Maintenance

You might read the commit logs and think "This must be abandonware! This hasn't been updated in 2y!" But! This is a mature project that solves a specific problem in ActiveRecord. It tends to only be updated when a new major version of ActiveRecord comes out and hence the infrequent updates.

## Install

Gemfile:

`gem "acts_as_archival"`

Any models you want to be archival should have the columns `archive_number` (String) and `archived_at` (DateTime).

i.e. `rails g migration AddAAAToPost archive_number archived_at:datetime`

Any dependent-destroy AAA model associated to an AAA model will be archived with its parent.

_If you're stuck on Rails 4.0x/3x/2x, check out the older tags/branches, which are no longer in active development._

## Example

``` ruby
class Hole < ActiveRecord::Base
  acts_as_archival
  has_many :rats, dependent: :destroy
end

class Rat < ActiveRecord::Base
  acts_as_archival
end
```

### Simple interactions & scopes

``` ruby
h = Hole.create                  #
h.archived?                      # => false
h.archive!                       # => true
h.archived?                      # => true
h.archive_number                 # => "b56876de48a5dcfe71b2c13eec15e4a2"
h.archived_at                    # => Thu, 01 Jan 2012 01:49:21 -0400
h.unarchive!                     # => true
h.archived?                      # => false
h.archive_number                 # => nil
h.archived_at                    # => nil
```

### Associations

``` ruby
h = Hole.create                  #
r = h.rats.create                #
h.archive!                       # => true
h.archive_number                 # => "b56876de48a5dcfe71b2c13eec15e4a2"
r.archived_at                    # => Thu, 01 Jan 2012 01:52:12 -0400
r.archived?                      # => true
h.unarchive!                     # => true
h.archive_number                 # => nil
r.archived_at                    # => nil
r.archived?                      # => false
```

### Relations

```ruby
Hole.create!
Hole.create!
Hole.create!

holes = Hole.all

# All records in the relation will be archived with the same archive_number.
# Dependent/Destroy relationships will be archived, and callbacks will still be honored.
holes.archive_all!              # => [array of Hole records in the relation]

holes.first.archive_number      # => "b56876de48a5dcfe71b2c13eec15e4a2"
holes.last.archive_number       # => "b56876de48a5dcfe71b2c13eec15e4a2"

holes.unarchive_all!            # => [array of Hole records in the relation]
```

### Scopes

``` ruby
h = Hole.create
Hole.archived.size               # => 0
Hole.unarchived.size             # => 1
h.archive!
Hole.archived.size               # => 1
Hole.unarchived.size             # => 0
```

### Utility methods

``` ruby
h = Hole.create                  #
h.archival?                   # => true
Hole.archival?                # => true
```

### Options

When defining an AAA model, it is is possible to make it unmodifiable
when it is archived by passing `readonly_when_archived: true` to the
`acts_as_archival` call in your model.

``` ruby
class CantTouchThis < ActiveRecord::Base
  acts_as_archival readonly_when_archived: true
end

record = CantTouchThis.create(foo: "bar")
record.archive!                              # => true
record.foo = "I want this to work"
record.save                                  # => false
record.errors.full_messages.first            # => "Cannot modify an archived record."
```

### Callbacks

AAA models have four additional callbacks to do any necessary cleanup or other processing before and after archiving and unarchiving, and can additionally halt the archive callback chain.

``` ruby
class Hole < ActiveRecord::Base
  acts_as_archival

  # runs before #archive!
  before_archive :some_method_before_archiving

  # runs after #archive!
  after_archive :some_method_after_archiving

  # runs before #unarchive!
  before_unarchive :some_method_before_unarchiving

  # runs after #unarchive!
  after_unarchive :some_method_after_unarchiving

  # ... implement those methods
end
```

#### Halting the callback chain

* Rails 4.2 - the callback method should return a `false`/`nil` value.
* Rails 5.x - the callback should `throw(:abort)`/`raise(:abort)`.

## Caveats

1. This will only work on associations that are dependent destroy. It
should be trival to change that or make it optional.
1. If you would like to work on this, you will need to setup sqlite on your development machine. Alternately, you can disable specific dev dependencies in the gemspec and test_helper and ask for help.

## Testing

Running the tests should be as easy as:

```  bash
script/setup                 # bundles, makes databases with permissions
rake                         # run tests on latest Rails
appraisal rake               # run tests on all versions of Rails
```

Check out [more on appraisal](https://github.com/thoughtbot/appraisal#usage) if you need to add new versions of things or run into a version bug.

## Help Wanted

We'd love to have your help making this better! If you have ideas for features this should implement or you think the code sucks, let us know. And PRs are greatly appreciated. :+1:

## Thanks

ActsAsParanoid and PermanentRecords were both inspirations for this:

* http://github.com/technoweenie/acts_as_paranoid
* http://github.com/fastestforward/permanent_records

## Contributors

* Joel Meador
* Michael Kuehl
* Matthew Gordon
* Vojtech Salbaba
* David Jones
* Dave Woodward
* Miles Sterrett
* James Hill
* Maarten Claes
* Anthony Panozzo
* Aaron Milam
* Anton Rieder
* Josh Menden
* Sergey Gnuskov

Thanks!

*Copyright (c) 2009-2017 Expected Behavior, LLC, released under the MIT license*
