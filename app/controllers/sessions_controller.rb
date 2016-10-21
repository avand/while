class SessionsController < ApplicationController

  def create
    auth = request.env["omniauth.auth"]

    user = User.find_or_create_by uid: auth["uid"]

    user.update({
      name: auth["info"]["name"],
      email: auth["info"]["email"],
      image: auth["info"]["image"]
    })

    session[:current_user_id] = user.id

    redirect_to items_path
  end

  def destroy
    session.delete :current_user_id

    redirect_to root_path
  end

end
