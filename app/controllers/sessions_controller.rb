class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    # if user(found by email) and password matches then
    # log_in/redirect
    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page.
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      remember user
      redirect_to user
    else
      # was flash but in order to get users_login_test.rb to pass
      # .now is needed
      flash.now[:danger] = 'Invalid email/password combination'
      # Not quite right!
      # Create an error message.
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
