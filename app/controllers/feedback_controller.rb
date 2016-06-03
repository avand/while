class FeedbackController < ApplicationController

  def create
    ApplicationMailer.feedback(current_user, params[:message]).deliver

    redirect_to request.referer || root_path, notice: "Thanks for the feedback."
  end

end
