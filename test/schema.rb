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

  create_table :callback_archival4s, :force => true do |t|
    t.column :settable_field, :string
    t.column :archive_number, :string
    t.column :archived_at, :datetime
  end

  create_table :callback_archival5s, :force => true do |t|
    t.column :settable_field, :string
    t.column :archive_number, :string
    t.column :archived_at, :datetime
  end
end
