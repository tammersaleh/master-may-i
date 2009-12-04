# = Functional test Shoulda macros
#
# These macros are very useful.  Use them.
#
# == Example
#
#
#   class NotesControllerTest < ActionController::TestCase
#     setup :activate_authlogic
#     
#     as_a_logged_in_user do
#       who_can_manage :notes do
#         context "on GET to /notes/new" do
#           setup { get :new }
#           should_not_set_the_flash
#           should_render_template :new
#         end
#         ...
#       end
#   
#       who_cannot_manage :notes do
#         context "on GET to /notes/new" do
#           setup { get :new }
#           should_be_denied_as_user
#         end
#   
#         context "given a note" do
#           setup { @note = Factory(:note) }
#   
#           context "on GET to /notes/:id" do
#             setup { get :show, :id => @note }
#             should_be_denied_as_user
#           end
#           ...
#         end
#       end
#     end
#   
#     as_a_visitor do
#       who_cannot_manage :notes do
#         context "on GET to /notes/new" do
#           setup { get :new }
#           should_be_denied_as_visitor
#         end
#   
#         context "on POST to /notes" do
#           setup { post :create, :note => {} }
#           should_be_denied_as_visitor
#         end
#         ...
#       end
#     end
#   end

class ActionController::TestCase
  # Context macro that creates a logged in user 
  #
  # It uses the :user Factory Girl factory (which must exist) and assigns the
  # user to @logged_in_user
  #
  # @yield Block for adding other should and context statements.
  def self.as_a_logged_in_user(&blk)
    context "as a logged in user" do
      setup { @logged_in_user = login_as Factory(:user) }
      merge_block(&blk)
    end
  end

  # Context macro that ensures there is no logged in user
  #
  # @yield Block for adding other should and context statements.
  def self.as_a_visitor(&blk)
    context "as a visitor" do
      setup { logout }
      merge_block(&blk)
    end
  end

  # Context macro that ensures that the @logged_in_user is authorized on all
  # actions for the given model.
  #
  # This macro makes use of Mocha stubbing to force all of the authorization
  # methods on the given model to return true for the @logged_in_user instance.
  # It is meant to be used in conjunction with +as_a_visitor+ and
  # +as_a_logged_in_user+.
  #
  # @param plural_model_name [Symbol] The pluralized name of the model that the 
  #                                   @logged_in_user instance should be allowed 
  #                                   to manage.
  #
  # @yield Block for adding other should and context statements.
  def self.who_can_manage(plural_model_name, &blk)
    context "who can manage #{plural_model_name}" do
      setup do
        klass = plural_model_name.to_s.singularize.camelcase.constantize
        stub_all_authorization_methods_on_class(klass, @logged_in_user, true)
      end
      merge_block(&blk)
    end
  end

  # Context macro that ensures that the @logged_in_user is not authorized on
  # all actions for the given model.
  #
  # This macro makes use of Mocha stubbing to force all of the authorization
  # methods on the given model to return false for the @logged_in_user
  # instance.  It is meant to be used in conjunction with +as_a_visitor+ and
  # +as_a_logged_in_user+.
  #
  # @param plural_model_name [Symbol] The pluralized name of the model that the 
  #                                   @logged_in_user instance should not be 
  #                                   allowed to manage.
  #
  # @yield Block for adding other should and context statements.
  def self.who_cannot_manage(plural_model_name, &blk)
    context "who can't manage #{plural_model_name}" do
      setup do
        klass = plural_model_name.to_s.singularize.camelcase.constantize
        stub_all_authorization_methods_on_class(klass, @logged_in_user, false)
      end
      merge_block(&blk)
    end
  end

  # Should statement that ensures that the user is denied access after trying
  # to reach a protected page.
  #
  # It ensures the user is redirected to the
  # permission_denied_redirect_for_user url and that the
  # permission_denied_flash_for_user flash message is set.
  def self.should_be_denied_as_user
    should "tell the user they aren't authorized" do
      assert_contains flash.values, @controller.send(:permission_denied_flash_for_user)
    end

    should "redirect user due to authorization" do
      assert_redirected_to @controller.send(:permission_denied_redirect_for_user)
    end
  end

  # Should statement that ensures that the visitor is denied access after trying
  # to reach a protected page.
  #
  # It ensures the visitor is redirected to the
  # +@controller.permission_denied_redirect_for_visitor+ url and that the
  # flash is set to +@controller.permission_denied_flash_for_visitor+.
  def self.should_be_denied_as_visitor
    should "tell the visitor they aren't authorized" do
      assert_contains flash.values, @controller.send(:permission_denied_flash_for_visitor)
    end

    should "redirect visitor due to authorization" do
      assert_redirected_to @controller.send(:permission_denied_redirect_for_visitor)
    end
  end

  # Helper method for +who_can_manage+ and +who_cannot_manage+ that takes care
  # of stubbing out the authorization methods.
  def stub_all_authorization_methods_on_class(klass, user, return_value)
    klass.stubs(:creatable_by?).with(user).returns(return_value)
    klass.any_instance.stubs(:editable_by?).with(user).returns(return_value)
    klass.any_instance.stubs(:readable_by?).with(user).returns(return_value)
    klass.any_instance.stubs(:destroyable_by?).with(user).returns(return_value)
  end

  # Helper method that logs the given user in.
  #
  # @param user [User] User that is logged in.
  # @return [User] The same user
  def login_as(user)
    UserSession.create(user)
    return user
  end

  # Helper method that removes any logged in sessions.
  # @return [nil]
  def logout
    UserSession.find && UserSession.find.destroy
    return nil
  end
end
