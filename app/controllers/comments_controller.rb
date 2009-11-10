class CommentsController < ApplicationController
  before_filter :authenticate, :only => [:create]

  def create
    if params[:post_id].nil? || params[:content].nil?
      flash[:error] = "post, user and content required"
      redirect_to :back
    else
      begin
        @u = current_user
        @c = Comment.create!(params.merge(:user_id => @u.get(:id), :user_name => @u.get(:login)))

        flash[:notice] = "comment created correctly"

        redirect_to :back
      rescue Exception => ex
        flash[:error] = "Error creating comment: #{ex.message}"
        redirect_to :back
      end
    end
  end

end
