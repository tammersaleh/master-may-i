require 'test_helper'

class PostTest < ActiveSupport::TestCase
  setup :activate_authlogic

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
