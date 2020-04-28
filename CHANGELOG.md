# CHANGELOG

## 2.0.0 – (UNRELEASED)

* **BREAKING CHANGE** Drop support for Rails 4.2
* **BREAKING CHANGE** Removed deprecated methods
* Fix Rails 6 deprecation warnings

## 1.4.0 - July 10, 2019
* **BREAKING CHANGE** drop support for rails 4.1
* **BREAKING CHANGE** drop support for Ruby <2.4
* **BUGFIX** polymorphic associations that are archived/unarchived can be acted on safely if they share the same ID.
* add support officially for rails 5.2
* sqlite upgrades for various rails
* new methods `#archive_all!` and `#unarchive_all` that can be called off scopes


## 1.3.0 - October 21, 2017
* deprecate `#archive` and `#unarchive` in favor of `#archive!` and `#unarchive!` [#36](https://github.com/expectedbehavior/acts_as_archival/pull/36)

## 1.2.0 - March 19, 2017
* **BREAKING CHANGE** the utility instance and class method `is_archival?` is now `archival?`. `is_archival?` is deprecated and will be removed
* hard dependency on rails 4.1+ – this shouldn't break anything since it was de facto before, but worth mentioning
* minor refactoring through most code
* much work done to make automatic checks worthwhile (travis/rubocop)
* general test cleanup
* drop hard dependency on mysql and postresql in tests

## 1.1.1 - April 10, 2016
* Update the way the `::unarchived` scope is generated using `::not` instead of manually building SQL, which should be better for complex queries

## 1.1.0 - April 10, 2016
* **BREAKING CHANGE** obsolete mainline rails 3 and rails 4.0.x support because: they are EOL'ed for > 1y
* add rails 4.2 automated tests
* add rails 5 support
* test and document callbacks better - Thanks, Aaron Milam
* **BUGFIX** remove a bunch of deprecations
* **BUGFIX** improve compatibility with various new versions of software like mysql when testing

## 1.0.0 - April 5, 2016
* **BREAKING CHANGE** make `#archived?` return an actual boolean value

## 0.6.1 - July 24, 2014
* Fix deprecation warnings on Rails 4.1
* Test suite now runs against multiple versions of Rails
* Fully automated test suite setup

## 0.6.0 - April 14, 2014
* **BREAKING CHANGE** (possibly): Some refactoring to modern gem module idioms instead of old school plugins
* Officially support PostgreSQL
* Switch default testing to use sqlite, mysql, and postgres instead of just mysql
* Major upgrades to test suite

## 0.5.3 - May 17, 2013
* Major refactoring of archiving/unarchiving logic into nice command classes instead of big ball of ARec voodoo. Thanks, Marten Claes!

## 0.5.2
* **BREAKING CHANGE** (possibly): removed the scope constants, so if you were using them, you should stop
* **BUGFIX** fix scoping combinations with relations for Rails 4
* More changes to support Rails 4

## 0.5.1
* update to use .table_name for archived scope

## 0.5.0
* Rails 4.0.0b1 support. Thanks, James Hill!

## 0.4.5
* possibly allow rails 2&3 to work when dealing with associations
* add some logging when archive/unarchive doesn't work

## 0.4.4
* **BUGFIX** Callbacks were being called twice because of how we were defining them

## 0.4.3
* Fix spelling error

## 0.4.2
* Change homepage to the github repo

## 0.4.1
* remove explicit activesupport gem'ing
* update documentation for using plugin version with rails 3.0x

## 0.4.0
* **BUGFIX**: when `archive`/`unarchive` fail, they now return false instead of nil
* Rails 3.2 compatibility -- **Possibly Rails 3.0 incompatible due to ARec differences**
* Gemified!
* Super Duper Major test re-organization
