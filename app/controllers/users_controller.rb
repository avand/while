class UsersController < ApplicationController

  before_action :require_current_user, only: :bootstrap

  layout "public"

  def new
    redirect_to items_path if current_user.present?
  end

  def bootstrap
    play = current_user.items.create name: "Try While"
    movies = current_user.items.create name: "Movies to watch 🎬"
    vacation = current_user.items.create name: "Go on vacation 🌴"

    movies.children.create name: "Aladdin"
    movies.children.create name: "Cool Runnings"
    movies.children.create name: "Great Expectations"
    movies.children.create name: "Interstellar"
    movies.children.create name: "Terminator 2: Judgement Day"

    pack = vacation.children.create name: "Pack"
    pack.children.create name: "Socks "
    pack.children.create name: "Underwear"
    pack.children.create name: "Travel-sized toothpaste"

    tickets = vacation.children.create name: "Buy plane tickets"

    camera = vacation.children.create name: "Camera 📷"
    camera.children.create name: "Charge batteries"

    redirect_to items_path
  end

end
