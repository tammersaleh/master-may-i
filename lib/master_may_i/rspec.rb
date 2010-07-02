RSpec::Matchers.define :record_the_creating_user do
  match do |klass|
    # This is done so the matcher works whether the subject is 
    # a class or an instance.
    klass = klass.class unless klass.is_a?(Class)
    factory_name = klass.name.underscore

    old_user = ActiveRecord::Base.user_from_session
    ActiveRecord::Base.user_from_session = user = Factory(:user)
    record = Factory(factory_name, :creator => nil)
    ActiveRecord::Base.user_from_session = old_user

    record.creator && record.creator == user
  end
end

RSpec::Matchers.define :be_returned_via_listable_by do |user|
  match do |record|
    klass = record.class
    records = klass.listable_by(user)
    records.include?(record)
  end
end

