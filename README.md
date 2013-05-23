# ActsAsArchival

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

## Install
Rails 3.2 and up

`gem install acts_as_archival`

or in your Gemfile

`gem "acts_as_archival"`

Rails 3.0x:

`rails plugin install http://github.com/expectedbehavior/acts_as_archival.git -r rails3.0x`

Rails 2:

`script/plugin install http://github.com/expectedbehavior/acts_as_archival.git -r rails2`

Any models you want to be archival should have the columns
`archive_number`(String) and `archived_at` (DateTime).

i.e. `rails g migration AddAAAToPost archive_number archived_at:datetime`

Any dependent-destroy model connected to an AAA model will be
archived with its parent.

## Example

``` ruby
class Hole < ActiveRecord::Base
  acts_as_archival
  has_many :rats, :dependent => :destroy
end

class Rat < ActiveRecord::Base
  acts_as_archival
end
```

``` ruby
>> Hole.archived.size               # => 0
>> Hole.is_archival?                # => true
>> hole = Hole.create
>> Hole.unarchived.size             # => 1
>> hole.is_archival?                # => true
>> hole.archived?                   # => false

>> hole.rats.create
>> hole.archive                     # archive hole and rat
>> hole.archive_number              # => 8c9f03f9d....
>> hole.rats.first.archive_number   # => 8c9f03f9d....
>> hole.rats.first.archived?        # => 8c9f03f9d....
>> hole.archived?                   # => 8c9f03f9d....
>> Rat.archived.size                # => 1
>> Hole.archived.size               # => 1

>> Hole.unarchived.size             # => 0
>> Rat.unarchived.size              # => 0
>> hole.unarchive
>> Hole.archived.size               # => 0
>> Hole.unarchived.size             # => 1
>> Rat.archived.size                # => 0
>> Rat.unarchived.size              # => 1
```

## Caveats

1. This will only work on associations that are dependent destroy. It
should be trival to change that or make it optional.
1. It will only work for Rails 2.2 and up, because we are using
`named_scope`/`scope`. You can check out [permanent records](http://github.com/fastestforward/permanent_records) for a way
to conditionally add the functionality to older Rails installations.
1. If you would like to work on this, you will need to setup sqlite, postgres, and mysql on your development machine. Alternately, you can disable specific dev dependencies in the gemspec and test_helper and ask for help.

## Testing

Because this plugin makes use of transactions we're testing it (mostly) on
sqlite. Running the tests should
be as easy as:

```  bash
bundle
test/script/db_setup    # makes the databases with the correct permissions (for mySQL)
rake
```

## Options

When defining an AAA model, it is is possible to make it unmodifiable
when it is archived by passing `:readonly_when_archived => true` to the
`acts_as_archival` call in your model.

``` ruby
class CantTouchThis < ActiveRecord::Base
  acts_as_archival :readonly_when_archived => true
end

>> record = CantTouchThis.create(:foo => "bar")
>> record.archive                               # => true
>> record.foo = "I want this to work"
>> record.save                                  # => false
>> record.errors.full_messages.first            # => "Cannot modify an archived record."
```

## Help Wanted

How do I write a postgresql script for setting up the db?

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
* Marten Claes

Thanks!

*Copyright (c) 2009-2013 Expected Behavior, LLC, released under the MIT license*
