# Rails 4.0 and before do not deal correctly with newer versions of mysql, so we're
# gonna force a non-null primary ID for old versions of Rails just as new ones do.
if (ActiveRecord.version <=> Gem::Version.new("4.1.0")) < 0
  class ActiveRecord::ConnectionAdapters::Mysql2Adapter
    NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
  end
end

ActiveRecord::Schema.define(:version => 1) do
  create_table :archivals, :force => true do |t|
    t.column :name, :string
    t.column :archival_id, :integer
    t.column :archive_number, :string
    t.column :archived_at, :datetime
  end

  create_table :exploders, :force => true do |t|
    t.column :archival_id, :integer
    t.column :archive_number, :string
    t.column :archived_at, :datetime
  end

  ###
  # The classes above are used to test database-specific
  # things in PG and MySQL, and we don't need to do all
  # the tests there.
  if "SQLite" == ActiveRecord::Base.connection.adapter_name
    create_table :archival_kids, :force => true do |t|
      t.column :archival_id, :integer
      t.column :archive_number, :string
      t.column :archived_at, :datetime
    end

    create_table :archival_grandkids, :force => true do |t|
      t.column :archival_kid_id, :integer
      t.column :archive_number, :string
      t.column :archived_at, :datetime
    end

    create_table :independent_archivals, :force => true do |t|
      t.column :name, :string
      t.column :archival_id, :integer
      t.column :archive_number, :string
      t.column :archived_at, :datetime
    end

    create_table :plains, :force => true do |t|
      t.column :name, :string
      t.column :archival_id, :integer
    end

    create_table :mass_attribute_protecteds, :force => true do |t|
      t.column :name, :string
      t.column :archive_number, :string
      t.column :archived_at, :datetime
    end

    create_table :readonly_when_archiveds, :force => true do |t|
      t.column :name, :string
      t.column :archive_number, :string
      t.column :archived_at, :datetime
    end

    create_table :missing_archived_ats, :force => true do |t|
      t.column :name,   :string
      t.column :archive_number, :string
    end

    create_table :missing_archive_numbers, :force => true do |t|
      t.column :name,   :string
      t.column :archived_at, :datetime
    end

    create_table :polys, :force => true do |t|
      t.references :archiveable, :polymorphic => true
      t.column :archive_number, :string
      t.column :archived_at, :datetime
    end

    create_table :legacy, :force => true do |t|
      t.column :name, :string
      t.column :archive_number, :string
      t.column :archived_at, :datetime
    end

    create_table :application_record_rows, :force => true do |t|
      t.column :archive_number, :string
      t.column :archived_at, :datetime
    end
  end
end
