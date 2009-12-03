# Behavior for remembering the user who created this record.
#
# That user is recorded as the creator (since they might not be the same user
# who "owns" the record)

# I add authorization query methods to every ActiveRecord model (through ActiveRecord::Base).
#
# Each model is given the following methods:
#
# == Class methods:
#
#   Model.creatable?
#   Model.creatable_by? user
#
# == Instance methods:
#
#   @model.readable?
#   @model.readable_by? user
#   @model.editable?
#   @model.editable_by? user
#   @model.destroyable?
#   @model.destroyable_by? user
#
# == Customization
#
# The xxx_by? methods all return true by default, and should be redefined by
# each model in turn.
#
# Each of the creatable?, readable?, editable? and destroyable? methods simply
# delegate to the xxx_by? methods, using the currently logged in user.
#
# *Do not override the creatable?, readable?, editable? or destroyable?
# methods.*

module MasterMayI
  module ActiveRecordExtensions
    module ClassMethods
      # Should the current user be able to create a record?
      def creatable?
        creatable_by?(user_from_session)
      end

      # Should the given user be able to create a record?  This method should be
      # redefined inside the Model.
      def creatable_by?(user)
        true
      end

      # Returns the currently logged in user (via Authlogic)
      def user_from_session
        UserSession.find && UserSession.find.user
      rescue Authlogic::Session::Activation::NotActivatedError
        nil
      end

      def records_creating_user(opts_hash = {})
        opts = HashWithIndifferentAccess.new(opts_hash)
        association_name = (opts[:as] || :creator).to_sym

        before_create :set_creating_user_from_session
        unless reflect_on_association(association_name)
          if association_name == :user
            belongs_to :user
          else
            belongs_to association_name, :class_name => "User"
          end
        end

        define_method :set_creating_user_from_session do
          # user_from_session is from ActiveRecordSecurity
          self.send("#{association_name}=", user_from_session)
        end

        define_method :created_by? do |user|
          return false unless user
          self.send(association_name).id == user.id
        end
      end
    end

    module InstanceMethods
      # Should the current user be able to read this record?
      def readable?
        readable_by?(user_from_session)
      end

      # Should the given user be able to read this record?  This method should be
      # redefined inside the Model.
      def readable_by?(user)
        true
      end

      # Should the current user be able to edit this record?
      def editable?
        editable_by?(user_from_session)
      end

      # Should the given user be able to edit this record?  This method should be
      # redefined inside the Model.
      def editable_by?(user)
        true
      end

      # Should the current user be able to destroy this record?
      def destroyable?
        destroyable_by?(user_from_session)
      end

      # Should the given user be able to destroy this record?  This method should be
      # redefined inside the Model.
      def destroyable_by?(user)
        true
      end

      # Returns the currently logged in user (via Authlogic)
      def user_from_session
        self.class.user_from_session
      end
    end
  end
end

class ActiveRecord::Base
  extend MasterMayI::ActiveRecordExtensions::ClassMethods
  include MasterMayI::ActiveRecordExtensions::InstanceMethods
end
