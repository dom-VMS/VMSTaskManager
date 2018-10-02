class RemoveTagTypes < ActiveRecord::Migration[5.1]
  def up
    drop_table :tag_types
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
