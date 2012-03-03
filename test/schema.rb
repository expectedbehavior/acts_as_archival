ActiveRecord::Schema.define(:version => 1) do

  create_table :archivals, :force => true do |t|
    t.column :name, :string
    t.column :archival_id, :integer
    t.column :archive_number, :string
    t.column :archived_at, :datetime
  end

  create_table :independent_kids, :force => true do |t|
    t.column :name, :string
    t.column :archival_id, :integer
    t.column :archive_number, :string
    t.column :archived_at, :datetime
  end

  create_table :plains, :force => true do |t|
    t.column :name, :string
    t.column :archival_id, :integer
  end

  create_table :missing_archived_ats, :force => true do |t|
    t.column :name,   :string
    t.column :archive_number, :string
  end

  create_table :missing_archive_numbers, :force => true do |t|
    t.column :name,   :string
    t.column :archived_at, :datetime
  end

  create_table :holes, :force => true do |t|
    t.column :number, :integer
    t.column :archive_number, :string
    t.column :archived_at, :datetime
  end

  create_table :muskrats, :force => true do |t|
    t.column :name, :string
    t.column :archive_number, :string
    t.column :archived_at, :datetime
    t.references :hole
  end

  create_table :fleas, :force => true do |t|
    t.column :name, :string
    t.column :archive_number, :string
    t.column :archived_at, :datetime
    t.references :muskrat
  end

  create_table :squirrels, :force => true do |t|
    t.column :name, :string
    t.column :archive_number, :string
    t.column :archived_at, :datetime
    t.references :hole
  end

  create_table :moles, :force => true do |t|
    t.column :name, :string
    t.references :hole
  end

  create_table :ships, :force => true do |t|
    t.column :name, :string
    t.column :archive_number, :string
    t.column :archived_at, :datetime
  end

  create_table :rats, :force => true do |t|
    t.column :name, :string
    t.column :archive_number, :string
    t.column :archived_at, :datetime
    t.references :ship
  end

  create_table :oranges, :force => true do |t|
    t.column :name, :string
    t.column :archive_number, :string
    t.column :archived_at, :datetime
    t.references :ship
  end

  create_table :snakes, :force => true do |t|
    t.string   :color
    t.string   :archive_number
    t.datetime :archived_at
  end

  create_table :beavers, :force => true do |t|
    t.integer  :how_much_wood_can_it_chuck
    t.string   :archive_number
    t.datetime :archived_at
  end

  create_table :ticks, :force => true do |t|
    t.string :archive_number
    t.datetime :archived_at
  end

  create_table :ixodidaes, :force => true do |t|
    t.references :ticks
    t.integer :warm_blooded_id
    t.string :warm_blooded_type
    t.string :archive_number
    t.datetime :archived_at
  end
end
