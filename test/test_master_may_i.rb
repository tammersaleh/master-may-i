require 'helper'

class User < ActiveRecord::Base
  acts_as_authentic
end

class UserSession < Authlogic::Session::Base
end

class Post < ActiveRecord::Base
  records_creating_user
end

class Note < ActiveRecord::Base
  records_creating_user :as => "user"

  def self.creatable_by?(user)
    user and user.username == "sue-create"
  end

  def readable_by?(user)
    user and user.username == "sue-read"
  end

  def editable_by?(user)
    user and user.username == "sue-edit"
  end

  def destroyable_by?(user)
    user and user.username == "sue-destroy"
  end
end

class NoteTest < ActiveSupport::TestCase
  setup :activate_authlogic
  setup { Post.destroy_all }

  should_record_creating_user :as => "user"

  should_be_creatable_by("boy named sue-create")    { Factory(:user, :username => "sue-create")  }
  should_not_be_creatable_by("everyone")            { nil }

  context "a note" do
    setup { @note = Factory(:note) }
    subject { @note }

    should_be_readable_by("boy named sue-read")       { Factory(:user, :username => "sue-read")    }
    should_be_editable_by("boy named sue-edit")       { Factory(:user, :username => "sue-edit")    }
    should_be_destroyable_by("boy named sue-destroy") { Factory(:user, :username => "sue-destroy") }

    should_not_be_readable_by(   "everyone") { nil }
    should_not_be_editable_by(   "everyone") { nil }
    should_not_be_destroyable_by("everyone") { nil }
  end
end

class PostTest < ActiveSupport::TestCase
  setup :activate_authlogic
  setup { Post.destroy_all }

  should_record_creating_user

  should_be_creatable_by("everyone") { nil }

  context "a post" do
    setup { @post = Factory(:post) }
    subject { @post }

    should_be_readable_by(   "everyone") { nil }
    should_be_editable_by(   "everyone") { nil }
    should_be_destroyable_by("everyone") { nil }
  end
end
