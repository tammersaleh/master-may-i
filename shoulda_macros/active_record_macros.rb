# = Unit test Shoulda macros
#
# These macros are very useful.  Use them.
#
# == Example
#
#   class NoteTest < ActiveSupport::TestCase
#     setup :activate_authlogic
#   
#     should_record_creating_user :as => "user"
#   
#     should_be_creatable_by("boy named sue-create") { Factory(:user, :username => "sue-create")  }
#     should_not_be_creatable_by("everyone")         { nil }
#   
#     context "a note" do
#       setup { @note = Factory(:note) }
#       subject { @note }
#   
#       should_be_readable_by("boy named sue-read")       { Factory(:user, :username => "sue-read")    }
#       should_be_editable_by("boy named sue-edit")       { Factory(:user, :username => "sue-edit")    }
#       should_be_destroyable_by("boy named sue-destroy") { Factory(:user, :username => "sue-destroy") }
#   
#       should_not_be_readable_by(   "everyone") { nil }
#       should_not_be_editable_by(   "everyone") { nil }
#       should_not_be_destroyable_by("everyone") { nil }
#     end
#   end

class ActiveSupport::TestCase
  # Ensures that a new instance is +creatable_by+ the user returned by the given block.
  #
  # @param [String] test_name string describing the user type in question.
  # @yield Block should return a user record to test against.
  #
  # @see MasterMayI::ActiveRecordExtensions::ClassMethods#creatable_by?
  def self.should_be_creatable_by(test_name, &user_block)
    should "be creatable by #{test_name}" do
      assert subject.class.creatable_by?(instance_eval(&user_block))
    end
  end

  # Ensures that a new instance is not +creatable_by+ the user returned by the given block.
  #
  # @param [String] test_name string describing the user type in question.
  # @yield Block should return a user record to test against.
  #
  # @see MasterMayI::ActiveRecordExtensions::ClassMethods#creatable_by?
  def self.should_not_be_creatable_by(test_name, &user_block)
    should "not be creatable by #{test_name}" do
      assert !subject.class.creatable_by?(instance_eval(&user_block))
    end
  end

  # Ensures that +subject+ is +readable_by+ the user returned by the given block.
  #
  # @param [String] test_name string describing the user type in question.
  # @yield Block should return a user record to test against.
  #
  # @see MasterMayI::ActiveRecordExtensions::InstanceMethods#readable_by?
  def self.should_be_readable_by(test_name, &user_block)
    should "be readable by #{test_name}" do
      assert subject.readable_by?(instance_eval(&user_block))
    end
  end

  # Ensures that +subject+ is not +readable_by+ the user returned by the given block.
  #
  # @param [String] test_name string describing the user type in question.
  # @yield Block should return a user record to test against.
  #
  # @see MasterMayI::ActiveRecordExtensions::InstanceMethods#readable_by?
  def self.should_not_be_readable_by(test_name, &user_block)
    should "not be readable by #{test_name}" do
      assert !subject.readable_by?(instance_eval(&user_block))
    end
  end

  # Ensures that +subject+ is +editable_by+ the user returned by the given block.
  #
  # @param [String] test_name string describing the user type in question.
  # @yield Block should return a user record to test against.
  #
  # @see MasterMayI::ActiveRecordExtensions::InstanceMethods#editable_by?
  def self.should_be_editable_by(test_name, &user_block)
    should "be editable by #{test_name}" do
      assert subject.editable_by?(instance_eval(&user_block))
    end
  end

  # Ensures that +subject+ is not +editable_by+ the user returned by the given block.
  #
  # @param [String] test_name string describing the user type in question.
  # @yield Block should return a user record to test against.
  #
  # @see MasterMayI::ActiveRecordExtensions::InstanceMethods#editable_by?
  def self.should_not_be_editable_by(test_name, &user_block)
    should "not be editable by #{test_name}" do
      assert !subject.editable_by?(instance_eval(&user_block))
    end
  end
  
  # Ensures that +subject+ is +destroyable_by+ the user returned by the given block.
  #
  # @param [String] test_name string describing the user type in question.
  # @yield Block should return a user record to test against.
  #
  # @see MasterMayI::ActiveRecordExtensions::InstanceMethods#destroyable_by?
  def self.should_be_destroyable_by(test_name, &user_block)
    should "be destroyable by #{test_name}" do
      assert subject.destroyable_by?(instance_eval(&user_block))
    end
  end

  # Ensures that +subject+ is not +destroyable_by+ the user returned by the given block.
  #
  # @param [String] test_name string describing the user type in question.
  # @yield Block should return a user record to test against.
  #
  # @see MasterMayI::ActiveRecordExtensions::InstanceMethods#destroyable_by?
  def self.should_not_be_destroyable_by(test_name, &user_block)
    should "not be destroyable by #{test_name}" do
      assert !subject.destroyable_by?(instance_eval(&user_block))
    end
  end

  # Ensures that newly created records correctly record the user from the Authlogic session.
  #
  # @option opts [Symbol] :as (:creator) The name of the association that holds the creating user.
  # @see MasterMayI::ActiveRecordExtensions::ClassMethods#records_creating_user
  def self.should_record_creating_user(opts = {})
    association_name = (opts[:as] || :creator).to_sym

    should_belong_to association_name

    context "when there's a logged in user" do
      setup do
        Authlogic::Session::Base.controller = Authlogic::TestCase::MockController.new
        UserSession.create(@user = Factory(:user))
      end

      context "a new record" do
        setup { @record = Factory(subject.class.name.underscore, association_name => nil) }

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

