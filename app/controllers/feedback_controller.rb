class FeedbackController < ApplicationController

  before_action :require_current_user

  def create
    ApplicationMailer.feedback(current_user, params[:message]).deliver

    redirect_to request.referer || root_path, notice: "Thanks for the feedback."
  end

end
