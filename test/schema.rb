ActiveRecord::Schema.define(:version => 1) do
  
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
  
  create_table :kitties, :force => true do |t|
    t.column :name,   :string
    t.column :archive_number, :string
  end
  
  create_table :puppies, :force => true do |t|
    t.column :name,   :string
    t.column :archived_at, :datetime
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
end
