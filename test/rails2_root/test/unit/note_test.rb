require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  setup :activate_authlogic

  should_record_creating_user :as => "user"

  should_be_creatable_by("boy named sue-create")    { Factory(:user, :username => "sue-create")  }
  should_not_be_creatable_by("everyone")            { nil }

  context "a note" do
    setup { @note = Factory(:note) }
    subject { @note }

    should_be_returned_via_listable_by("boy named sue-read") { Factory(:user, :username => "sue-read") }
    should_not_be_returned_via_listable_by("everyone")       { nil }

    should_be_readable_by("boy named sue-read")       { Factory(:user, :username => "sue-read")    }
    should_be_editable_by("boy named sue-edit")       { Factory(:user, :username => "sue-edit")    }
    should_be_destroyable_by("boy named sue-destroy") { Factory(:user, :username => "sue-destroy") }

    should_not_be_readable_by(   "everyone") { nil }
    should_not_be_editable_by(   "everyone") { nil }
    should_not_be_destroyable_by("everyone") { nil }
  end
  
end
