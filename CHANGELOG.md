# Changes!

## 0.5.2
* More changes to support Rails 4
* fix scoping combinations with relations for Rails 4
* BREAKING CHANGE (possibly): removed the scope constants, so if you were using them, you should stop

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
