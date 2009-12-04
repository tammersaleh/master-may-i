# I add authorization query methods to every ActiveRecord model (through
# ActiveRecord::Base).  Each model is given the following methods:
#
# === {MasterMayI::ActiveRecordExtensions::ClassMethods Class methods}:
#
# * +Model.creatable_by? user+ 
# * +Model.creatable?+ 
#
# === {MasterMayI::ActiveRecordExtensions::InstanceMethods Instance methods}:
#
# * +@model.readable_by? user+ 
# * +@model.readable?+
# * +@model.editable_by? user+ 
# * +@model.editable?+
# * +@model.destroyable_by? user+ 
# * +@model.destroyable?+
#
# == Usage
#
# Use these methods throughout your application to determine who can do what.
#
#   link_to_if @note.editable?, "edit note", edit_note_url
#
# == Customization
#
# Each of the +creatable_by?+, +readable_by?+, +editable_by?+ and
# +destroyable_by?+ methods return true by default, and should be redefined by
# each model in turn.
#
#  class Note < ActiveRecord::Base
#    def self.creatable_by?(user)
#      user
#    end
#
#    def editable_by?(user)
#      return false unless user
#      user.administrator? or created_by?(user)
#    end
#  end
#
# Each of the +creatable?+, +readable?+, +editable?+ and +destroyable?+ methods simply
# delegate to the +xxx_by?+ methods, passing in the currently logged in user.
# The currently logged in user is returned by the
# {MasterMayI::ActiveRecordExtensions::ClassMethods#user_from_session
# +user_from_session+} method, which looks at the Authlogic UserSession model.
#
# === Do not override the creatable?, readable?, editable? or destroyable?  methods.  Redefine the creatable_by?, readable_by?, editable_by? and destroyable_by? methods instead.

module MasterMayI::ActiveRecordExtensions
  module ClassMethods # :nodoc:
    # Should the current user be able to create a record? Delegates to +creatable_by?+
    def creatable?
      creatable_by?(user_from_session)
    end

    # Should the given user be able to create a record?  This method should be
    # redefined inside the model.
    def creatable_by?(user)
      true
    end

    # Returns the currently logged in user via the Authlogic UserSession class.
    def user_from_session
      UserSession.find && UserSession.find.user
    rescue Authlogic::Session::Activation::NotActivatedError
      nil
    end

    # Record the +user_from_session+ as the +creator+ when creating a new record.
    #
    # This macro also adds the +@model.created_by?(user)+ method.
    #
    # @see MasterMayI::ActiveRecordExtensions::ClassMethods#user_from_session
    # @option opts [Symbol] :as (:creator) The name of the association that holds the creating user.
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
        self.send("#{association_name}=", user_from_session)
      end

      define_method :created_by? do |user|
        return false unless user
        self.send(association_name).id == user.id
      end
    end
  end

  module InstanceMethods
    # Should the current user be able to read this record?  Delegates to +readable_by?+.
    def readable?
      readable_by?(user_from_session)
    end

    # Should the given user be able to read this record?  This method should be
    # redefined inside the model.
    def readable_by?(user)
      true
    end

    # Should the current user be able to edit this record?  Delegates to +editable_by?+.
    def editable?
      editable_by?(user_from_session)
    end

    # Should the given user be able to edit this record?  This method should be
    # redefined inside the model.
    def editable_by?(user)
      true
    end

    # Should the current user be able to destroy this record?  Delegates to +destroyable_by?+.
    def destroyable?
      destroyable_by?(user_from_session)
    end

    # Should the given user be able to destroy this record?  This method should be
    # redefined inside the model.
    def destroyable_by?(user)
      true
    end

    # Returns the currently logged in user via the Authlogic UserSession class.
    # @see MasterMayI::ActiveRecordExtensions::ClassMethods#user_from_session
    def user_from_session
      self.class.user_from_session
    end
  end
end

class ActiveRecord::Base # :nodoc:
  extend MasterMayI::ActiveRecordExtensions::ClassMethods
  include MasterMayI::ActiveRecordExtensions::InstanceMethods
end
