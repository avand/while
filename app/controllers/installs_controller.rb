class InstallsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path
  end

  def new
    if current_user.present?
      redirect_to items_path
    else
      load_and_validate_user_and_install
    end
  end

  def create
    load_and_validate_user_and_install

    @install.destroy

    session[:current_user_id] = @user.id
  end

private

  def load_and_validate_user_and_install
    @user = User.find_by_hashid(params[:user_hashid])
    @install = Install.find_by_hashid(params[:install_hashid])

    raise ActiveRecord::RecordNotFound unless @user.install == @install
  end

end
