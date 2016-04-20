class Item < ApplicationRecord

  has_ancestry

  scope :completed, -> { where completed: true }
  scope :cleared, -> { where cleared: true }
  scope :not_cleared, -> { where cleared: [nil, false] }

  belongs_to :user

end
