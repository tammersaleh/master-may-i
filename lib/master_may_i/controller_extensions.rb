module MasterMayI::ControllerExtensions
  def protects_restful_actions
    include MasterMayI::ControllerExtensions::Filters
  end

  module Filters
    def self.included(controller)
      controller.before_filter :ensure_can_create_record,  :only => [:new, :create]

      controller.before_filter :ensure_can_show_record,    :only => :show
      controller.before_filter :ensure_can_edit_record,    :only => [:edit, :update]
      controller.before_filter :ensure_can_destroy_record, :only => :destroy
    end

    def ensure_can_create_record
      deny_access unless resource_class.creatable?
    end

    def ensure_can_show_record
      deny_access unless resource.readable?
    end

    def ensure_can_edit_record
      deny_access unless resource.editable?
    end

    def ensure_can_destroy_record
      deny_access unless resource.destroyable?
    end
  end

  # Foo
  module InstanceMethods
    def self.included(controller)
      controller.helper_method :current_user_session, :current_user, :logged_in?
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def logged_in?
      !! current_user
    end

    def require_user
      deny_access unless current_user
    end

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

    def permission_denied_flash_for_user
      "You don't have permission to access this page."
    end

    def permission_denied_flash_for_visitor
      "Please login."
    end

    def permission_denied_redirect_for_user
      root_url
    end

    def permission_denied_redirect_for_visitor
      login_url
    end

    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or(url)
      redirect_to(session[:return_to] || url)
      session[:return_to] = nil
    end
  end
end

class ActionController::Base # :nodoc:
  extend MasterMayI::ControllerExtensions
  include MasterMayI::ControllerExtensions::InstanceMethods
end