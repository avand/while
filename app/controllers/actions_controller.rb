class ActionsController < ApplicationController

  before_action :require_current_user, only: :log

  def log
    current_user.log_action params[:name]

    head :success
  end

end
