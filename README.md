# ActsAsArchival

Atomically archive object trees in your activerecord models.

We had the problem that acts_as_paranoid and similar plugins/gems
always work on a record by record basis and made it very difficult to
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

i.e. `script/generate migration AddAAAToPost archive_number:string archived_at:datetime`

Any dependent-destroy objects connected to an AAA model will be
archived with its parent.

## Example

``` ruby
class Hole < ActiveRecord::Base
  acts_as_archival
  has_many :moles, :dependent => :destroy
end

class Mole < ActiveRecord::Base
  acts_as_archival
end
```

``` ruby
>> Hole.archived.size               # => 0
>> Hole.is_archival?                # => true
>> h = Hole.create
>> Hole.unarchived.size             # => 1
>> h.is_archival?                   # => true
>> h.archived?                      # => false
>> h.muskrats.create
>> h.archive                        # archive hole and muskrat
>> h.archive_number                 # => 8c9f03f9d....
>> h.muskrats.first.archive_number  # => 8c9f03f9d....
>> h.archived?                      # => 8c9f03f9d....
>> Hole.archived.size               # => 1
>> Hole.unarchived.size             # => 0
>> h.unarchive
>> Hole.archived.size               # => 0
>> Hole.unarchived.size             # => 1
```

## Caveats

1. This will only work on associations that are dependent destroy. It
should be trival to change that or make it optional.
1. It will only work for Rails 2.2 and up, because we are using
`named_scope`/`scope`. You can check out permanent records for a way
to conditionally add the functionality to older Rails installations.
1. This will only work (well) on databases with transactions (mysql,
postgres, etc.).

## Testing

Because this plugin makes use of transactions we're testing it on
MySQL instead of the more convenient sqlite. Running the tests should
be as easy as:

```  bash
bundle
test/script/db_setup    # makes the databases with the correct permissions (for mySQL)
rake
```

## Help Wanted

It would be cool if someone could check if this thing works on
postgres and if not, submit a patch / let us know about it!

## Thanks

ActsAsParanoid and PermanentRecords were both inspirations for this:
http://github.com/technoweenie/acts_as_paranoid
http://github.com/fastestforward/permanent_records

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
