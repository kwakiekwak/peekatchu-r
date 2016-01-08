class MainPagesController < ApplicationController
  def home
    @challenges = Challenge.all
    # if params[:newest]
    #   @challenges = Challenge.all(-6..-1)
    # end

  end

  # def new
  #   @user = User.new
  # end

  # def create
  #   @user = User.new(user_params)
  #   if @user.save
  #     log_in @user
  #     flash[:success] = "Welcome to Peekatchu-r Challenge!"
  #     redirect_to @user
  #   else
  #     render :new
  #   end
  # end

  def about
  end

  def help
  end

  def contact
  end

   private

  # def user_params
  #   params.require(:user).permit(:name, :images, :email, :password,
  #                                :password_confirmation)
  # end
end
