require 'digest'

class SessionsController < ApplicationController

  before_filter :authenticate, :only => [:destroy]

  def new
    if logged?
      flash[:notice] = "You are already signed in"
      @u = current_user
      redirect_to :controller => 'users', :action => 'show', :id => @u.get(:id)
    end
  end

  def create
      unless logged?
        # Verify user
        @u = User.find(:by_login, params[:login])
        raise Exception.new("Authentication failure, check your login and password") unless @u

        # Verify password
        hash = @u.get(:password_hash)
        hashed = Digest::MD5.hexdigest(params[:password])
        raise Exception.new("Authentication failure, check your login and password") if hash != hashed

        # Create session
        @s = Session.create!(:user_id => @u.get(:id))

        session[:auth] = @s.get(:id)
        session[:user] = @u.get(:id)
      else
        @u = current_user
      end

      redirect_to :controller => 'users', :action => 'show', :id => @u.get(:id)
    rescue Exception => ex
      flash[:error] = ex.message
      redirect_to :back
  end

  def destroy
      @s = Session.find(:by_id, session[:auth])
      @s.destroy!

      session[:user] = nil
      session[:auth] = nil

      flash[:notice] = 'See you soon!'
      redirect_to :controller => 'sessions', :action => 'new'
    rescue Exception => ex
      flash[:error] = "Error signing out: #{ex.message}"
      redirect_to :back
  end
end
