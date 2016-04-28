class ActionsController < ApplicationController

  before_action :require_current_user
  before_action :require_current_admin, only: :index

  def log
    current_user.log_action params[:name]

    head :success
  end

  def index
    @actions = Action.order("occurred_at desc").limit(500).includes(:user)
  end

end
