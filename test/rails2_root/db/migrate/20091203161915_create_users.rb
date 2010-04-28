class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :username, :string
      t.column :creator_id, :integer
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
    end
  end

  def self.down
    drop_table :users
  end
end
