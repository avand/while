class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  after_action :track_current_user

  def current_user
    if session[:current_user_id].present?
      @current_user ||= User.find(session[:current_user_id])
    end
  end
  helper_method :current_user

  def require_current_user
    if current_user.blank?
      redirect_to root_path, alert: "Sorry, you must be signed in to do that!"
    end
  end

private

  def track_current_user
    current_user.try :update_column, :last_visited_at, Time.now
    current_user.try :increment!, :request_count
  end

end
