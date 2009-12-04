class ActionController::TestCase
  def self.as_a_logged_in_user(&blk)
    context "as a logged in user" do
      setup { @logged_in_user = login_as Factory(:user) }
      merge_block(&blk)
    end
  end

  def self.as_a_visitor(&blk)
    context "as a visitor" do
      setup { logout }
      merge_block(&blk)
    end
  end

  def self.who_can_manage(plural_model_name, &blk)
    context "who can manage #{plural_model_name}" do
      setup do
        klass = plural_model_name.to_s.singularize.camelcase.constantize
        stub_all_authorization_methods_on_class(klass, @logged_in_user, true)
      end
      merge_block(&blk)
    end
  end

  def self.who_cannot_manage(plural_model_name, &blk)
    context "who can't manage #{plural_model_name}" do
      setup do
        klass = plural_model_name.to_s.singularize.camelcase.constantize
        stub_all_authorization_methods_on_class(klass, @logged_in_user, false)
      end
      merge_block(&blk)
    end
  end

  def self.should_be_denied_as_user
    should "tell the user they aren't authorized" do
      assert_contains flash.values, @controller.send(:permission_denied_flash_for_user)
    end

    should "redirect user due to authorization" do
      assert_redirected_to @controller.send(:permission_denied_redirect_for_user)
    end
  end

  def self.should_be_denied_as_visitor
    should "tell the visitor they aren't authorized" do
      assert_contains flash.values, @controller.send(:permission_denied_flash_for_visitor)
    end

    should "redirect visitor due to authorization" do
      assert_redirected_to @controller.send(:permission_denied_redirect_for_visitor)
    end
  end

  def stub_all_authorization_methods_on_class(klass, user, return_value)
    klass.stubs(:creatable_by?).with(user).returns(return_value)
    klass.any_instance.stubs(:editable_by?).with(user).returns(return_value)
    klass.any_instance.stubs(:readable_by?).with(user).returns(return_value)
    klass.any_instance.stubs(:destroyable_by?).with(user).returns(return_value)
  end

  def login_as(user)
    UserSession.create(user)
    return user
  end

  def logout
    UserSession.find && UserSession.find.destroy
    return nil
  end
end
