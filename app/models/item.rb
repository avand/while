class Item < ApplicationRecord

  has_ancestry

  scope :completed, -> { where completed: true }

  belongs_to :user

end
