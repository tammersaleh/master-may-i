require 'test_helper'

class PostTest < ActiveSupport::TestCase
  setup :activate_authlogic

  should_record_creating_user
  should_validate_presence_of :creator

  should_be_creatable_by("everyone") { nil }

  context "when there's not a logged in user" do
    setup do
      Authlogic::Session::Base.controller = Authlogic::TestCase::MockController.new
      UserSession.find && UserSession.destroy
    end

    context "a new record" do
      should "not blow up" do
        @record = Factory(:post)
      end
    end
  end

  context "a post" do
    setup { @post = Factory(:post) }
    subject { @post }

    should_be_readable_by(   "everyone") { nil }
    should_be_editable_by(   "everyone") { nil }
    should_be_destroyable_by("everyone") { nil }
  end
end
