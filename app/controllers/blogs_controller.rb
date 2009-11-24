class BlogsController < ApplicationController

  before_filter :authenticate, :only => [:create, :new, :edit, :update, :destroy]

  def index
      @blogs = Blog.find(:all)
    rescue Exception => ex
      flash[:error] = "There has been some error retrieving blog data: #{ex.message}"
      redirect_to :back
  end

  def show
      @blog = Blog.find(:by_id, params[:id])
      @posts = @blog.relation(:posts)
      @user = current_user
    rescue Exception => ex
      flash[:error] = "There has been some error retrieving blog data: #{ex.message}"
      redirect_to :back
  end

  def new
  end

  def create
    if params[:title].nil? || params[:description].nil?
      flash[:error] = "Title and content are required"
      redirect_to :back
    else
      begin
        @u = current_user
        @b = Blog.create!(params.merge(:user_id => @u.get(:id)))

        flash[:notice] = "Blog created successfully"

        redirect_to :controller => 'users', :action => 'show', :id => @u.get(:id)
      rescue Exception => ex
        flash[:error] = "Error creating blog: #{ex.message}"
        redirect_to :back
      end
    end
  end

  def edit
      @blog = Blog.find(:by_id, params[:id])
      @posts = @blog.relation(:posts)
    rescue Exception => ex
      flash[:error] = "Error retrieving blog data: #{ex.message}"
      redirect_to :back
  end

  def update
      @blog = Blog.find(:by_id, params[:id])
      @blog.set(:description, params[:description])
      @blog.update!
      flash[:notice] = "The blog '#{@blog.get(:title)}' has been udapted"
      redirect_to :controller => 'users', :action => 'show', :id => current_user.get(:id)

    rescue Exception => ex
      flash[:error] = "Error updating blog data: #{ex.message}"
      redirect_to :back
  end

  def destroy
      @blog = Blog.find(:by_id, params[:id])
      flash[:notice] = "The blog '#{@blog.get(:title)}' has been destroyed"
      @blog.destroy!
      redirect_to :controller => 'users', :action => 'show', :id => current_user.get(:id)

    rescue Exception => ex
      flash[:error] = "Error destroying blog data: #{ex.message}"
      redirect_to :back
  end

end
