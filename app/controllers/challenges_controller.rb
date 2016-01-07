class ChallengesController < ApplicationController

  @@descending = false

  def index
    # @challenges = Challenge.paginate(page: params[:page])
    # @challenges = Challenge.all
    if params[:query]
      # search_by = params[:search].to_sym
      challenge_list = Challenge.all
      @challenges = []
      challenge_list.each do |challenge|
        if challenge[:title].downcase.include? params[:query].downcase
          @challenges << challenge
        end
      end
      return @challenges
    end
    @paginate = true
    @challenges = Challenge.page(params[:page]).per(5)

  end

  def show
    @challenge = Challenge.find(params[:id])
    @post = Post.new(:challenge => @challenge)

  end

  def new
    @challenge = Challenge.new
    @post = Post.new
  end

  def create
    @challenge = Challenge.new(challenge_params)
    # this sets user_id into challenge (might not need it)
    @challenge.user_id = session[:user_id]
    # @post = @challenge.posts.build(params[:post])
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

  def sort
    if @@descending
      @challenges = Challenge.page(params[:page]).per(5).order(params[:id] + " desc")
    else
      @challenges = Challenge.page(params[:page]).per(5).order(params[:id])
    end
      @@descending = !@@descending
    render :index
  end



private
  def challenge_params
    params.require(:challenge).permit(:images, :title, :description, :user_id, :category_id)
  end
end
