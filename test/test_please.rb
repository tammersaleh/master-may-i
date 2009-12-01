require 'helper'

class Post < ActiveRecord::Base
  records_creating_user
end

class Note < ActiveRecord::Base
  records_creating_user :as => "user"
end

class User < ActiveRecord::Base
  acts_as_authentic
end

class UserSession < Authlogic::Session::Base
end

class NoteTest < ActiveSupport::TestCase
  setup :activate_authlogic
  setup { Post.destroy_all }

  should_record_creating_user :as => "user"
end

class PostTest < ActiveSupport::TestCase
  setup :activate_authlogic
  setup { Post.destroy_all }

  should_record_creating_user

  should "default to allowing create" do
    assert Post.creatable?
  end

  should "default to allowing edit" do
    assert Factory(:post).editable?
  end

  should "default to allowing read" do
    assert Factory(:post).readable?
  end

  should "default to allowing destroy" do
    assert Factory(:post).destroyable?
  end
end
