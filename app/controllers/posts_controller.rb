class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
    @id = params[:id]
    puts params[:id]
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = session[:user_id]
    # @post.challenge_id = @post.challenge
    if @post.save
      flash[:success] = "Post was created"
      redirect_to(@post.challenge)
    else
      flash[:danger] = "Post could NOT be created"
      redirect_to(@post.challenge)
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
    if @post.destroy
      flash[:success] = "Lead it to posts instaed of new_post"
      redirect_to challenge_path(@post.challenge_id)
    else
      flash[:danger] = "You cannot delete this post"
      redirect_to challenge_path(@post.challenge_id)
    end
  end

  private
  def post_params
    params.require(:post).permit(:comments, :images, :challenge_id)
  end
end

