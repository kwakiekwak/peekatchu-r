class MainPagesController < ApplicationController
  def home
    @challenges = Challenge.all
  end

  def about
  end

  def help
  end

  def contact
  end
end
