require 'digest'

class SessionsController < ApplicationController

  before_filter :authenticate, :only => [:destroy]

  def new
    if logged?
      flash[:notice] = "you are already sign in"
      @u = current_user
      redirect_to :controller => 'users', :action => 'show', :id => @u.get(:id)
    end
  end

  def create
    begin
      raise Exception.new("You must provide a login and password in order to proceed") if params[:login].nil? || params[:password].nil?

      unless logged?

        @u = User.find(:by_login, params[:login])

        hash = @u.get(:password_hash)
        hashed = Digest::MD5.hexdigest(params[:password])

        raise Excepiton.new("Authentication failure, check your login and password") if hash != hashed

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
  end

  def destroy
    begin
      @s = Session.find(:by_id, session[:auth])
      @s.destroy!

      session[:user] = nil
      session[:auth] = nil

      redirect_to :controller => 'sessions', :action => 'new'
    rescue Exception => ex
      flash[:error] = "Error signing out: #{ex.message}"
      redirect_to :back
    end
  end
end
