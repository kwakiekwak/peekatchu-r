class ChallengesController < ApplicationController

  def index
    # @challenges = Challenge.paginate(page: params[:page])
    @challenges = Challenge.all

  end

  def show
    @challenge = Challenge.find(params[:id])
  end

  def new
    @challenge = Challenge.new
  end

  def create
    @challenge = Challenge.new(challenge_params)
    @challenge.user_id = session[:user_id]
    if @challenge.save
      flash[:success] = "You have created a new Challenge"
      redirect_to challenges_path
    else
      render :new
    end
  end

  def edit
    @challenge = Challenge.find(params[:id])
  end

  def update
    @challenge = Challenge.find(params[:id])
    if @challenge.update_attributes(challenge_params)
      flash[:success] = "Challenge updated"
      redirect_to challenge_path(@challenge)
    else
      render :edit
    end
  end

  def destroy
    @challenge = Challenge.find(params[:id])
    @challenge.destroy
      flash[:succes] = "Challenge destroyed"
      redirect_to new_challenge_path(@challenge)

  end



private
  def challenge_params
    params.require(:challenge).permit(:images, :title, :description, :category_id)
  end
end
