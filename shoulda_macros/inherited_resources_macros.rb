class ActionController::TestCase
  def self.as_a_user_who_can_manage(plural_model_name, &blk)
    context "as a user who can manage #{plural_model_name}" do
      setup do
        @logged_in_user = Factory(:user)
        UserSession.create(@logged_in_user)

        klass = plural_model_name.to_s.singularize.camelcase.constantize

        klass.stubs(:creatable_by?).with(@logged_in_user).returns(true)
        klass.any_instance.stubs(:editable_by?).with(@logged_in_user).returns(true)
        klass.any_instance.stubs(:readable_by?).with(@logged_in_user).returns(true)
        klass.any_instance.stubs(:destroyable_by?).with(@logged_in_user).returns(true)
      end
      merge_block(&blk)
    end
  end

  def self.as_a_user_who_cannot_manage(plural_model_name, &blk)
    context "as a user who can't manage #{plural_model_name}" do
      setup do
        @logged_in_user = Factory(:user)
        UserSession.create(@logged_in_user)

        klass = plural_model_name.to_s.singularize.camelcase.constantize

        klass.stubs(:creatable_by?).with(@logged_in_user).returns(false)
        klass.any_instance.stubs(:editable_by?).with(@logged_in_user).returns(false)
        klass.any_instance.stubs(:readable_by?).with(@logged_in_user).returns(false)
        klass.any_instance.stubs(:destroyable_by?).with(@logged_in_user).returns(false)
      end
      merge_block(&blk)
    end
  end
end
