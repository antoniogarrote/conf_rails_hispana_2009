class UsersController < ApplicationController

  before_filter :authenticate, :only => [:show]

  def new
  end

  def show
    begin
      @u = User.find(:by_id, params[:id])
      @blogs = @u.relation(:blogs)
    rescue Exception => ex
      flash[:error] = "Unknown user #{params[:id]}"
      @u = nil
    end
  end

  def create
    if params[:password] != params[:password_confirmation]
      flash[:error] = "Password confirmation doesn't match"
      redirect_to :back
    else
      begin
        @u = User.create!(params.reject{ |k,v| k == :password_confirmation})
        flash[:notice] = "user created correctly"
        redirect_to :controller => 'sessions', :action => 'new'
      rescue Exception => ex
        flash[:error] = "Error creating user: #{ex.message}"
        redirect_to :back
      end
    end
  end

  def edit
  end

end
