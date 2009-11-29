class ActiveSupport::TestCase
  def self.should_record_creating_user(opts = {})
    association_name = (opts[:as] || :creator).to_sym

    should_belong_to association_name

    context "when there's not a logged in user" do
      setup do
        Authlogic::Session::Base.controller = Authlogic::TestCase::MockController.new
        UserSession.find && UserSession.destroy
      end

      context "a new #{subject.class}" do
        should "not blow up" do
          @record = Factory(subject.class.name.underscore)
        end
      end
    end

    context "when there's a logged in user" do
      setup do
        Authlogic::Session::Base.controller = Authlogic::TestCase::MockController.new
        UserSession.create(@user = Factory(:user))
      end

      context "a new #{subject.class}" do
        setup { @record = Factory(subject.class.name.underscore) }

        should "record that user on create as #{association_name}" do
          assert_equal(@user, @record.send(association_name))
        end

        should "have been created by the user" do
          assert @record.created_by?(@user)
        end

        should "not have been created by another user" do
          assert !@record.created_by?(Factory(:user))
        end

        should "not have been created by nil" do
          assert !@record.created_by?(nil)
        end
      end
    end
  end
end

