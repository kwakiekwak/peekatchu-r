class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = session[:user_id]
    # @post.challenge_id = @post.challenge
    if @post.save
      flash[:success] = "Post was created"
      redirect_to posts_path
    else
      flash[:danger] = "Post could NOT be created"
      render :new
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update_attributes(post_params)
      flash[:success] = "get challenge/post together"
      redirect_to post_path(@post)
    else
      render :edit
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    flash[:success] = "Lead it to posts instaed of new_post"
    redirect_to posts_path
  end

  private
  def post_params
    params.require(:post).permit(:comments, :images)
  end
end
