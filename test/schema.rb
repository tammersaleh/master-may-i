ActiveRecord::Schema.define(:version => 1) do
	create_table :posts do |t|
		t.column :title, :string
		t.column :creator_id, :integer
	end

	create_table :notes do |t|
		t.column :title, :string
		t.column :user_id, :integer
	end

	create_table :users do |t|
		t.column :username, :string
		t.column :creator_id, :integer
    t.string :crypted_password
    t.string :password_salt
    t.string :persistence_token
	end
end
