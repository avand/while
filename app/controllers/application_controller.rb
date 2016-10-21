class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  after_action :track_current_user

  class AuthorizationRequired < StandardError; end
  class AdministratorRequired < StandardError; end
  class CurrentUserNotFound < StandardError; end

  if Rails.env.production?
    rescue_from AuthorizationRequired do |error|
      redirect_to root_path, alert: "Sorry, you must be signed in to do that!"
    end

    rescue_from AdministratorRequired do |error|
      redirect_to root_path, alert: "Sorry, you must be an admin to do that!"
    end

    rescue_from CurrentUserNotFound do |error|
      redirect_to log_out_path
    end
  end

  def current_user
    if session[:current_user_id].present?
      begin
        @current_user ||= User.find(session[:current_user_id])
      rescue ActiveRecord::RecordNotFound
        raise CurrentUserNotFound
      end
    end
  end
  helper_method :current_user

  def require_current_user
    raise AuthorizationRequired if current_user.blank?
  end

  def require_current_admin
    raise AdministratorRequired unless current_user.admin?
  end

private

  def track_current_user
    current_user.try :update_column, :last_visited_at, Time.now
    current_user.try :increment!, :request_count
  end

end
