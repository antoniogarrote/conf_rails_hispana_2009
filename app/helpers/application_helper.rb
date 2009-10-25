# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def logged?
    ! session[:user].nil?
  end

  def current_session
    session[:auth]
  end

  def current_user
    User.find(:by_id, session[:user])
  end

  def current_user_id
    session[:user]
  end
end
