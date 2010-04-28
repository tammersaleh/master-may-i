class Post < ActiveRecord::Base
  records_creating_user 
  validates_presence_of :creator
end
