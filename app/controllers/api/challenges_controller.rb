module API
  class ChallengesController < ApplicationController

    def index
      render json: Challenge.all
    end

    def show
      render json: Challenge.find(params[:id])
    end

  end
end
