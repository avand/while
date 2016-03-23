class SessionsController < ApplicationController

  def create
    info = request.env["omniauth.auth"]["info"]

    user = User.find_or_create_by uid: info["uid"]

    user.update({
      name: info["name"],
      email: info["email"],
      image: info["image"]
    })

    session[:current_user_id] = user.id

    redirect_to items_path, notice: "Welcome, #{user.name}."
  end

  def destroy
    session.delete :current_user_id

    redirect_to root_path
  end

end
