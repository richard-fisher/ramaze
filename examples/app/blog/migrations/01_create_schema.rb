# For more information on Sequel migrations see the following page:
# http://sequel.rubyforge.org/rdoc/files/doc/migration_rdoc.html
Sequel.migration do
  # The up() method and block is used to update a database to the current
  # migration.
  up do
    create_table(:users) do
      primary_key :id

      String :username, :null => false
      String :password, :null => false
    end

    create_table(:posts) do
      primary_key :id

      String :title, :null => false
      String :body , :null => false, :text => true

      Time :created_at
      Time :updated_at

      foreign_key :user_id, :users, :on_update => :cascade,
        :on_delete => :cascade, :key => :id
    end

    create_table(:comments) do
      primary_key :id

      String :username, :null => true
      String :comment , :null => false, :text => true

      Time :created_at

      foreign_key :post_id, :posts, :on_update => :cascade,
        :on_delete => :cascade, :key => :id

      foreign_key :user_id, :users, :on_update => :cascade,
        :on_delete => :cascade, :key => :id
    end
  end

  # The down() method and block is used to revert the changes introduced by the
  # up() block.
  down do
    drop_table(:comments)
    drop_table(:posts)
    drop_table(:users)
  end
end
