class User < ApplicationRecord

  has_many :items
  has_many :actions

  def log_action(name)
    actions.create name: name, occurred_at: Time.now
  end

end
