class Item < ApplicationRecord

  has_ancestry

  scope :completed, -> { where completed: true }

end
