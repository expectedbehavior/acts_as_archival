# Changes!

## Unreleased
* obsolete mainline rails 3 support because: it's been forever
* add rails 4.2 automated tests
* add rails 5 support
* remove a bunch of deprecations
* improve compatibility with various new versions of software like mysql when testing
* make `#archived?` return an actual boolean value

## 0.6.1
* Fix deprecation warnings on Rails 4.1
* Test suite now runs against multiple versions of Rails
* Fully automated test suite setup

## 0.6.0
* **BREAKING CHANGE** (possibly): Some refactoring to modern gem module idioms instead of old school plugins
* Officially support PostgreSQL
* Switch default testing to use sqlite, mysql, and postgres instead of just mysql
* Major upgrades to test suite

## 0.5.3
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
