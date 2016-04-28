class User < ApplicationRecord

  ADMIN_EMAILS = ["avand@avandamiri.com"]

  has_many :items
  has_many :actions

  def log_action(name)
    actions.create name: name, occurred_at: Time.now
  end

  def admin?
    email.in? ADMIN_EMAILS
  end

  def first_name
    name.split(" ").first
  end

  def last_name
    name.split(" ").last
  end

end
