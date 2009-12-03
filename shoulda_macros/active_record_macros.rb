class ActiveSupport::TestCase
  def self.should_be_creatable_by(test_name, &user_block)
    should "be creatable by #{test_name}" do
      assert subject.class.creatable_by?(instance_eval(&user_block))
    end
  end

  def self.should_not_be_creatable_by(test_name, &user_block)
    should "not be creatable by #{test_name}" do
      assert !subject.class.creatable_by?(instance_eval(&user_block))
    end
  end

  def self.should_be_readable_by(test_name, &user_block)
    should "be readable by #{test_name}" do
      assert subject.readable_by?(instance_eval(&user_block))
    end
  end

  def self.should_not_be_readable_by(test_name, &user_block)
    should "not be readable by #{test_name}" do
      assert !subject.readable_by?(instance_eval(&user_block))
    end
  end

  def self.should_be_editable_by(test_name, &user_block)
    should "be editable by #{test_name}" do
      assert subject.editable_by?(instance_eval(&user_block))
    end
  end

  def self.should_not_be_editable_by(test_name, &user_block)
    should "not be editable by #{test_name}" do
      assert !subject.editable_by?(instance_eval(&user_block))
    end
  end
  
  def self.should_be_destroyable_by(test_name, &user_block)
    should "be destroyable by #{test_name}" do
      assert subject.destroyable_by?(instance_eval(&user_block))
    end
  end

  def self.should_not_be_destroyable_by(test_name, &user_block)
    should "not be destroyable by #{test_name}" do
      assert !subject.destroyable_by?(instance_eval(&user_block))
    end
  end

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

