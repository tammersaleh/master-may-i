# Helper methods you probably want in your controller.
#
# Including this in your application controller gives you access to these
# helpers, and also to the
# {MasterMayI::ControllerExtensions::ClassMethods#protects_restful_actions
# +protects_restful_actions+} method.
#
#   class ApplicationController < ActionController::Base
#     include MasterMayI::ControllerExtensions
#     ...
#
module MasterMayI::ControllerExtensions
  def self.included(controller)
    controller.extend MasterMayI::ControllerExtensions::ClassMethods
    controller.helper_method :current_user_session, :current_user, :logged_in?
  end

  # Returns the current UserSession
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  # Returns the currently logged in user
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  # Returns whether or not there is a currently logged in user
  def logged_in?
    !! current_user
  end

  # A before filter which calls deny_access if there isn't a currently logged in user
  def require_user
    deny_access unless current_user
  end

  # All before filters eventually call deny_access.  deny_access stores the
  # current location in the session, sets the flash and redirects the user.  
  #
  # The flash, and where the user is redirected to are chosen based on
  # whether there is a logged in user, and are customizeable by overriding
  # the permission_denied_flash_for_user permission_denied_redirect_for_user
  # permission_denied_flash_for_visitor and
  # permission_denied_redirect_for_visitor methods
  #
  # @option opts [String] :flash 
  #   (permission_denied_flash_for_visitor or permission_denied_flash_for_user) 
  #   Flash message displayed after redirect.
  # @option opts [String] :redirect_to 
  #   (permission_denied_redirect_for_visitor or permission_denied_redirect_for_user) 
  #   URL the user is redirected to.
  #
  # @see MasterMayI::ControllerExtensions#permission_denied_redirect_for_user 
  #      permission_denied_redirect_for_user
  # @see MasterMayI::ControllerExtensions#permission_denied_flash_for_user 
  #      permission_denied_flash_for_user
  # @see MasterMayI::ControllerExtensions#permission_denied_redirect_for_visitor 
  #      permission_denied_redirect_for_visitor
  # @see MasterMayI::ControllerExtensions#permission_denied_flash_for_visitor 
  #      permission_denied_flash_for_visitor
  def deny_access(opts = {})
    if logged_in?
      opts[:flash]       ||= permission_denied_flash_for_user
      opts[:redirect_to] ||= permission_denied_redirect_for_user
    else
      opts[:flash]       ||= permission_denied_flash_for_visitor
      opts[:redirect_to] ||= permission_denied_redirect_for_visitor
    end

    store_location
    flash[:notice] = opts[:flash]
    redirect_to opts[:redirect_to]
  end

  # Used by deny_access.  Override to customize the flash message displayed
  # to users who are logged in, but not allowed to access the resource.
  def permission_denied_flash_for_user
    "You don't have permission to access this page."
  end

  # Used by deny_access.  Override to customize the flash message displayed
  # to visitors who are not yet logged in.
  def permission_denied_flash_for_visitor
    "Please login."
  end

  # Used by deny_access.  Override to customize the URL to which users who
  # are logged in, but not allowed to access the resource are redirected.
  def permission_denied_redirect_for_user
    root_url
  end

  # Used by deny_access.  Override to customize the URL to which visitors who
  # are not logged in are redirected.
  def permission_denied_redirect_for_visitor
    login_url
  end

  # Used by deny_access and redirect_back_or to store and later redirect to
  # the currently requested location
  def store_location
    session[:return_to] = request.request_uri
  end
  
  # Works in conjunction with store_location.  If there is a :return_to set
  # in the session, redirect the user there.  Otherwise, redirect the user to
  # the given url.
  def redirect_back_or(url)
    redirect_to(session[:return_to] || url)
    session[:return_to] = nil
  end

  module ClassMethods
    # Adds before filters to your InheritedResources controller that protect access to the resource.
    #
    # Only the +new+, +create+, +show+, +edit+, +update+, and +destroy+ actions
    # are covered.  Note that this does not protect the +index+ action, or
    # attempt to limit the records that are returned by +find(:all)+.
    #
    # The before filters make use of the
    # {MasterMayI::ControllerExtensions#deny_access deny_acces}
    # helper to set the flash, save the intended location, and redirect the user.
    #
    # @see MasterMayI::ControllerExtensions::Filters#ensure_can_create_record ensure_can_create_record
    # @see MasterMayI::ControllerExtensions::Filters#ensure_can_show_record ensure_can_show_record
    # @see MasterMayI::ControllerExtensions::Filters#ensure_can_edit_record ensure_can_edit_record
    # @see MasterMayI::ControllerExtensions::Filters#ensure_can_destroy_record ensure_can_destroy_record
    def protects_restful_actions
      include MasterMayI::ControllerExtensions::Filters
    end
  end

  module Filters
    def self.included(controller)
      controller.before_filter :ensure_can_create_record,  :only => [:new, :create]

      controller.before_filter :ensure_can_show_record,    :only => :show
      controller.before_filter :ensure_can_edit_record,    :only => [:edit, :update]
      controller.before_filter :ensure_can_destroy_record, :only => :destroy
    end

    # Stop unauthorized users from hitting +new+ or +create+
    def ensure_can_create_record
      deny_access unless resource_class.creatable?
    end

    # Stop unauthorized users from hitting +show+
    def ensure_can_show_record
      deny_access unless resource.readable?
    end

    # Stop unauthorized users from hitting +edit+ or +update+
    def ensure_can_edit_record
      deny_access unless resource.editable?
    end

    # Stop unauthorized users from hitting +destroy+
    def ensure_can_destroy_record
      deny_access unless resource.destroyable?
    end
  end
end
