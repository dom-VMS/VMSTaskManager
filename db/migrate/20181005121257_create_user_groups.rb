class CreateUserGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :user_groups do |t|
      t.belongs_to :user, index: true
      t.belongs_to :tag_type_option, index: true

      t.timestamps
    end
  end
end
