class UsersController < ApplicationController

  def new
    redirect_to items_path if current_user.present?
  end

end
