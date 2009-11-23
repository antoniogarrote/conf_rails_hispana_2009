class PostsController < ApplicationController

  before_filter :authenticate, :only => [:create, :new, :update, :edit]
  before_filter :verify_blog_and_owner, :only => [:new, :edit]

  def show
      @blog = Blog.find(:by_id, params[:blog_id])
      @post = Post.find(:by_id, params[:id])
      @comments = @post.relation(:comments)
      @user = current_user
    rescue Exception => ex
      flash[:error] = "Impossible to find blog: #{ex.message}"
      redirect_to :back
  end

  def new
    @blog = Blog.find(:by_id, params[:blog_id])
  end

  def create
    if params[:title].nil? || params[:content].nil? || params[:blog_id].nil?
      flash[:error] = "title, content, blog_id and user_id are required"
      redirect_to :back
    else
      @user_id = if params[:user_id].nil?
                   @u = current_user
                   @u.get(:id)
                 else
                   params[:user_id]
                 end

      if @user_id.nil?
        flash[:error] = "user_id are required"
        redirect_to :back
      else
        begin
          @p = Post.create!(params.merge(:user_id => @user_id))

          flash[:notice] = "post created correctly"

          redirect_to :controller => 'posts', :action => 'show', :id => @p.get(:id), :blog_id => params[:blog_id]
        rescue Exception => ex
          flash[:error] = "Error creating post: #{ex.message}"
          redirect_to :back
        end
      end
    end
  end

  def edit
    begin
      @blog = Blog.find(:by_id, params[:blog_id])
      @post = Post.find(:by_id, params[:id])
      @user = current_user
    rescue Exception => ex
      flash[:error] = "Impossible to find post: #{ex.message}"
      redirect_to :back
    end
  end

  def update
    begin
      @blog = Blog.find(:by_id, params[:id])
      @blog.set(:description, params[:description])
      @blog.update!
      flash[:notice] = "The post '#{@blog.get(:title)}' has been udapted"
      redirect_to :controller => 'blogs', :action => 'show', :id => params[:blog_id]

    rescue Exception => ex
      flash[:error] = "error updating blog data: #{ex.message}"
      redirect_to :back
    end
  end

  def destroy
    begin
      @post = Post.find(:by_id, params[:id])
      flash[:notice] = "The post '#{@post.get(:title)}' has been destroyed"
      @post.destroy!
      redirect_to :controller => 'blogs', :action => 'edit', :id => params[:blog_id]

    rescue Exception => ex
      flash[:error] = "error destroying post data: #{ex.message}"
      redirect_to :back
    end
  end

  private
 
  def verify_blog_and_owner
    if params[:blog_id]
      @blog = Blog.find :by_id, params[:blog_id]
      if @blog.get(:user_id) != current_user.get(:id)
        flash[:error] = "Hey you! This blog is not yours! You can't create a post."
        redirect_to :back
      end
    else
      flash[:error] = "A blog identifier is required to create a new post"
      redirect_to :back
    end
  end

end
