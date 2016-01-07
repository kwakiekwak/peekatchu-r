class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update, :destroy]
  before_action :admin_user,     only: :destroy

  @@descending = false

  def index
    if params[:query]
      # search_by = params[:search].to_sym
      user_list = User.all
      @users = []
      user_list.each do |user|
        if user.name.downcase.include? params[:query].downcase
          @users << user
        end
      end
      return @users
    end
    @paginate = true
    @users = User.page(params[:page]).per(5)

    # @users = User.search(params[:search]).paginate(per_page: 10, page: params[:page])
    # if params[:search]
    #   @u = User.search(params[:search]).order("created_at DESC")
    # else
    #   @u = User.order("created_at DESC")
    # end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to Peekatchu-r Challenge!"
      redirect_to @user
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # Handle a successful update
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    session[:user_id] = nil
    User.find(params[:id]).destroy
    flash[:success] = "User Deleted"
    redirect_to users_url

  end

  def sort
    if @@descending
      @paginate = true
      @users = User.page(params[:page]).per(5).order(params[:id] + " desc")
    else
      @paginate = true
      @users = User.page(params[:page]).per(5).order(params[:id])
    end
      @@descending = !@@descending
    render :index
  end


  private

  def user_params
    params.require(:user).permit(:name, :images, :email, :password,
                                 :password_confirmation)
  end

  # Before filters

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  # Confirms an admin user
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
