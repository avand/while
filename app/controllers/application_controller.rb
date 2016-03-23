class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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

end
