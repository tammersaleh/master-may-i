Factory.sequence(:name) {|i| "username#{i}" }

Factory.define :post do |f|
  f.title "New post"
  f.association :creator, :factory => :user
end

Factory.define :note do |f|
  f.title "New note"
end

Factory.define :user do |f|
  f.username              { Factory.next :name }
  f.password              "asdfasdf"
  f.password_confirmation "asdfasdf"
end
