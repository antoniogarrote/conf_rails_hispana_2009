# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout "application"

  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  after_filter :setup_authentication_views

  private

  def authenticate
    if session[:auth].nil?
      flash[:error] = "You must sign in first"
      redirect_to :controller => 'sessions', :action => 'new'
    end
  end

  def setup_authentication_views
    @view_user_id = session[:user]
  end

  def logged?
    ! session[:user].nil?
  end
  def current_user
    User.find(:by_id, session[:user])
  end

  def current_session
    Session.find(:by_id, session[:auth])
  end
end
