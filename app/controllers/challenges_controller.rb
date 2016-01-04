class ChallengesController < ApplicationController
  def index
    @challenges = Challenge.all
  end

  def new
    @challenge = Challenge.new
  end

  def create
    @challenge = Challenge.new(challenge_params)
    if @challenge.save
      flash[:success] = "You have created a new Challenge"
      redirect_to challenges_index_path
    else
      render :new
    end
  end

private
  def challenge_params
    params.require(:challenge).permit(:title, :description)
  end
end
